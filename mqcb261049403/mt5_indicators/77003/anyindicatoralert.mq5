//+------------------------------------------------------------------+
//|                                            AnyIndicatorAlert.mq5 |
//|                                              Ayaz Kakepoto  2026 |
//|                                                                  |
//|  Alerts, higher-timeframe reading and a repaint check for any     |
//|  indicator on the terminal, addressed by file name only. No       |
//|  source code of the watched indicator is needed.                  |
//+------------------------------------------------------------------+
#property copyright "Ayaz Kakepoto"
#property version   "1.00"
#property description "Watches any other indicator by name and alerts on its buffers."
#property description "EXPLORE mode lists every buffer it has, so you can see which one holds the signal."
#property description "It also re-reads closed bars and reports if the values change, which is repainting."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0

//--- Buffer 0 carries the watched indicator's chosen buffer, so your own
//--- EA can read it through iCustom instead of repeating this plumbing.
//--- It is filled only when the watched timeframe is the chart's own.
double BufOut[];

//--- how the tool is being used -------------------------------------
enum ENUM_RUN_MODE
  {
   MODE_EXPLORE = 0,   // EXPLORE - list the buffers, alert nothing
   MODE_WATCH   = 1    // WATCH - alert on the chosen buffer
  };

//--- what counts as a signal ----------------------------------------
enum ENUM_TRIGGER
  {
   TRIG_APPEARS      = 0,   // a value appears where the bar before was empty (arrows)
   TRIG_CROSS_UP     = 1,   // buffer crosses above Level
   TRIG_CROSS_DOWN   = 2,   // buffer crosses below Level
   TRIG_BUF_CROSS_UP = 3,   // buffer A crosses above buffer B
   TRIG_BUF_CROSS_DN = 4,   // buffer A crosses below buffer B
   TRIG_CHANGED      = 5    // the value simply changed from the previous bar
  };

//--- inputs ---------------------------------------------------------
input group           "Which indicator to watch"
//--- Deliberately empty. There is no indicator every terminal is certain to
//--- have, so naming one as a default would mean a failed load on any machine
//--- that lacks it, and a failed load inside the Strategy Tester ends the run
//--- whatever the code does about it. Type the name you want to watch.
input string          InpIndicator    = "";                  // Indicator file, e.g. Examples\RSI (required)
input string          InpParams       = "14";                // Its inputs, comma separated - blank for defaults
input ENUM_TIMEFRAMES InpTimeframe    = PERIOD_CURRENT;      // Read it on this timeframe
input bool            InpZeroIsEmpty  = false;               // This indicator writes 0 where it means "nothing"

input group           "What to do"
input ENUM_RUN_MODE   InpMode         = MODE_EXPLORE;        // Mode

input group           "EXPLORE settings"
input int             InpMaxBuffers   = 16;                  // How many buffers to probe
input int             InpExploreBars  = 12;                  // How many recent bars to print

input group           "WATCH settings"
input int             InpBufferA      = 0;                   // Buffer to watch
input int             InpBufferB      = 1;                   // Second buffer (only for buffer crosses)
input ENUM_TRIGGER    InpTrigger      = TRIG_APPEARS;        // Trigger
input double          InpLevel        = 70.0;                // Level (only for level crosses)
input bool            InpClosedBarOnly= true;                // Judge closed bars only

input group           "How to be told"
input bool            InpPopup        = true;                // Popup alert
input bool            InpSound        = false;               // Play a sound
input string          InpSoundFile    = "alert.wav";         // Sound file
input bool            InpPush         = false;               // Push notification to phone
input bool            InpEmail        = false;               // Email

input group           "Repaint check"
input bool            InpRepaintCheck = true;                // Re-read closed bars and report changes
input int             InpRepaintBars  = 50;                  // How many closed bars to keep watching
input double          InpTolerance    = 0.0;                 // Ignore changes smaller than this

//--- state ----------------------------------------------------------
int             g_handle   = INVALID_HANDLE;
ENUM_TIMEFRAMES g_tf       = PERIOD_CURRENT;
bool            g_explored = false;
datetime        g_lastBar  = 0;
datetime        g_alerted  = 0;
uint            g_waitFrom = 0;
uint            g_waitSaid = 0;
uint            g_noDataSaid = 0;
bool            g_readWarned = false;
bool            g_seeded     = false;   // first WATCH pass only records, it never fires

//--- what the snapshot pass found. A closed bar can change in two ways that
//--- mean different things: a value can arrive late on a bar that was blank
//--- (lag, as with fractals), or a value that was there can move or vanish
//--- (repainting, as with ZigZag). They are counted apart.
int             g_lateTotal  = 0;       // late arrivals, running total
int             g_repaints   = 0;       // moved or vanished, running total
uint            g_retryAt    = 0;       // next attempt to load the watched indicator
bool            g_loadSaid   = false;   // the "could not load" advice is printed once
int             g_lateCount  = 0;       // late arrivals found in the latest pass
datetime        g_lateBar    = 0;       // the newest of them
int             g_lateAge    = 0;       // bars after that bar closed
double          g_lateVal    = 0.0;

datetime        g_snapT[];
double          g_snapV[];

//+------------------------------------------------------------------+
//| Is this value one the indicator meant as "nothing here"?          |
//|                                                                   |
//| There is no single convention. Most use EMPTY_VALUE, but plenty    |
//| write a plain 0.0 instead - MetaQuotes' own ZigZag is one - and a  |
//| tool that only knows EMPTY_VALUE reads those buffers as a solid    |
//| line of zeros. Which of the two applies cannot be guessed from     |
//| outside, so it is an input and EXPLORE says when it matters.       |
//+------------------------------------------------------------------+
bool IsBlank(const double v)
  {
   if(!MathIsValidNumber(v))
      return(true);
   if(v == EMPTY_VALUE)
      return(true);
   if(MathAbs(v) > 1.0e300)
      return(true);
   if(InpZeroIsEmpty && v == 0.0)
      return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Two readings of the same bar - are they really different?         |
//+------------------------------------------------------------------+
bool Differs(const double a, const double b)
  {
   const bool ba = IsBlank(a);
   const bool bb = IsBlank(b);
   if(ba != bb)
      return(true);          // a value appeared or vanished - that is a change
   if(ba && bb)
      return(false);
   return(MathAbs(a - b) > InpTolerance);
  }

//+------------------------------------------------------------------+
//| Printable form of one buffer value                                |
//+------------------------------------------------------------------+
string Show(const double v)
  {
   if(IsBlank(v))
      return("     -");
   return(StringFormat("%10.5f", v));
  }

//+------------------------------------------------------------------+
//| Token classification for the parameter string                     |
//+------------------------------------------------------------------+
bool LooksLikeWholeNumber(const string s)
  {
   const int n = StringLen(s);
   if(n == 0)
      return(false);
   int i = 0;
   const ushort first = StringGetCharacter(s, 0);
   if(first == '-' || first == '+')
      i = 1;
   if(i >= n)
      return(false);
   for(; i < n; i++)
     {
      const ushort c = StringGetCharacter(s, i);
      if(c < '0' || c > '9')
         return(false);
     }
   return(true);
  }

bool LooksLikeDecimal(const string s)
  {
   const int n = StringLen(s);
   if(n == 0)
      return(false);
   bool sawDigit = false;
   bool sawPoint = false;
   for(int i = 0; i < n; i++)
     {
      const ushort c = StringGetCharacter(s, i);
      if(c >= '0' && c <= '9')
        {
         sawDigit = true;
         continue;
        }
      if(c == '.')
        {
         if(sawPoint)
            return(false);
         sawPoint = true;
         continue;
        }
      if((c == '-' || c == '+') && i == 0)
         continue;
      return(false);
     }
   return(sawDigit && sawPoint);
  }

//+------------------------------------------------------------------+
//| Build the MqlParam list the terminal needs to create the handle   |
//+------------------------------------------------------------------+
int BuildParams(MqlParam &out[])
  {
   string tok[];
   int count = 0;

   string trimmed = InpParams;
   StringTrimLeft(trimmed);
   StringTrimRight(trimmed);

   if(StringLen(trimmed) > 0)
      count = StringSplit(trimmed, ',', tok);

   ArrayResize(out, count + 1);

   out[0].type         = TYPE_STRING;
   out[0].string_value = InpIndicator;

   for(int i = 0; i < count; i++)
     {
      string t = tok[i];
      StringTrimLeft(t);
      StringTrimRight(t);

      const string low = StringToLower2(t);

      if(low == "true" || low == "false")
        {
         out[i + 1].type          = TYPE_BOOL;
         out[i + 1].integer_value = (low == "true") ? 1 : 0;
         continue;
        }
      if(LooksLikeWholeNumber(t))
        {
         out[i + 1].type          = TYPE_INT;
         out[i + 1].integer_value = (long)StringToInteger(t);
         continue;
        }
      if(LooksLikeDecimal(t))
        {
         out[i + 1].type         = TYPE_DOUBLE;
         out[i + 1].double_value = StringToDouble(t);
         continue;
        }
      out[i + 1].type         = TYPE_STRING;
      out[i + 1].string_value = t;
     }

   return(count + 1);
  }

//+------------------------------------------------------------------+
//| StringToLower works in place, so wrap it                          |
//+------------------------------------------------------------------+
string StringToLower2(const string s)
  {
   string c = s;
   StringToLower(c);
   return(c);
  }

//+------------------------------------------------------------------+
//| Say out loud what was passed, so the user can check it            |
//+------------------------------------------------------------------+
void ReportParams(const MqlParam &p[], const int total)
  {
   PrintFormat("  indicator : %s", InpIndicator);
   PrintFormat("  timeframe : %s", EnumToString(g_tf));
   if(total <= 1)
     {
      Print("  inputs    : none given, the indicator's own defaults are in use");
      return;
     }
   string line = "";
   for(int i = 1; i < total; i++)
     {
      string one;
      switch(p[i].type)
        {
         case TYPE_BOOL:   one = (p[i].integer_value != 0 ? "true" : "false") + (string)" (bool)";   break;
         case TYPE_INT:    one = IntegerToString(p[i].integer_value) + " (int)";                      break;
         case TYPE_DOUBLE: one = DoubleToString(p[i].double_value, 8) + " (double)";                  break;
         default:          one = "\"" + p[i].string_value + "\" (string)";                            break;
        }
      line += (i > 1 ? ", " : "") + one;
     }
   PrintFormat("  inputs    : %s", line);
   Print("  If the indicator misbehaves, the types above are the first thing to check.");
  }

//+------------------------------------------------------------------+
//| Init                                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Try to load the watched indicator.                                |
//|                                                                   |
//| A failure here is never fatal. The chart keeps the tool, says on   |
//| the chart what is wrong, and tries again, because the usual causes |
//| are a typo in the name or an indicator that has not been compiled  |
//| yet - both of which the user can fix without detaching anything.   |
//+------------------------------------------------------------------+
bool TryLoad()
  {
   string name = InpIndicator;
   StringTrimLeft(name);
   StringTrimRight(name);

   if(StringLen(name) == 0)
     {
      if(!g_loadSaid)
        {
         g_loadSaid = true;
         Print("AnyIndicatorAlert: nothing to watch yet.");
         Print("  Open the inputs and put a file name in 'Indicator file' - the path under");
         Print("  MQL5\\Indicators without the extension, for example  Examples\\RSI");
         Print("  Then leave Mode on EXPLORE and read the buffer table in this tab.");
        }
      Comment("AnyIndicatorAlert\n\nNothing to watch yet.\nOpen the inputs and set 'Indicator file',\nfor example  Examples\\RSI\n\nThen leave Mode on EXPLORE.");
      return(false);
     }

   MqlParam p[];
   const int total = BuildParams(p);

   ResetLastError();
   g_handle = IndicatorCreate(_Symbol, g_tf, IND_CUSTOM, total, p);

   if(g_handle == INVALID_HANDLE)
     {
      const int err = GetLastError();
      if(!g_loadSaid)
        {
         g_loadSaid = true;
         PrintFormat("AnyIndicatorAlert: could not load \"%s\" (error %d). It will keep trying.", InpIndicator, err);
         Print("  The name is the path under MQL5\\Indicators without the extension,");
         Print("  for example  Examples\\RSI  - one backslash in the inputs dialog.");
         Print("  If the name is right, the indicator may not be compiled, or the inputs");
         Print("  are the wrong count or the wrong types for it.");
        }
      Comment(StringFormat("AnyIndicatorAlert\nCould not load \"%s\" (error %d).\nCheck the name and that it is compiled. See the Experts log.",
                           InpIndicator, err));
      return(false);
     }

   g_loadSaid = false;
   Comment("");

   Print("------------------------------------------------------------------");
   Print("AnyIndicatorAlert");
   ReportParams(p, total);

   if(InpMode == MODE_EXPLORE)
      Print("  mode      : EXPLORE - nothing will be alerted, the buffers will be listed");
   else
      PrintFormat("  mode      : WATCH - buffer %d, trigger %s", InpBufferA, EnumToString(InpTrigger));

   if(InpZeroIsEmpty)
      Print("  zeros     : a plain 0 is being read as \"nothing here\"");

   Print("  The first reading can be empty while the indicator is still calculating.");
   Print("------------------------------------------------------------------");

   g_waitFrom = GetTickCount();
   g_waitSaid = g_waitFrom;
   return(true);
  }

//+------------------------------------------------------------------+
//| Init                                                              |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufOut, INDICATOR_CALCULATIONS);
   ArrayInitialize(BufOut, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "AnyIndicatorAlert");

   g_tf = (InpTimeframe == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : InpTimeframe;

   ArrayResize(g_snapT, 0);
   ArrayResize(g_snapV, 0);

   g_waitFrom = GetTickCount();
   g_waitSaid = g_waitFrom;
   g_retryAt  = g_waitFrom;

   TryLoad();                 // a failure is reported, not fatal
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinit                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_handle != INVALID_HANDLE)
      IndicatorRelease(g_handle);
   Comment("");
  }

//+------------------------------------------------------------------+
//| Read n values of one buffer starting at a bar index                |
//+------------------------------------------------------------------+
bool ReadBuffer(const int buf, const int startPos, const int n, double &dst[])
  {
   ArraySetAsSeries(dst, true);
   const int got = CopyBuffer(g_handle, buf, startPos, n, dst);
   return(got == n);
  }

//+------------------------------------------------------------------+
//| EXPLORE - probe every buffer and print what is in them.           |
//| Returns true once a table has been printed; false means nothing   |
//| was readable yet and it should be tried again on a later tick.    |
//+------------------------------------------------------------------+
bool Explore()
  {
   const int bars = MathMax(3, MathMin(InpExploreBars, 100));
   const int probe = MathMax(1, MathMin(InpMaxBuffers, 64));

   int    found = 0;
   int    real[64], zero[64], blank[64];
   double lo[64], hi[64];
   double col[64][100];

   for(int b = 0; b < probe; b++)
     {
      double v[];
      if(!ReadBuffer(b, 0, bars, v))
         break;                       // this buffer does not exist - stop

      real[b]  = 0;
      zero[b]  = 0;
      blank[b] = 0;
      lo[b] =  DBL_MAX;
      hi[b] = -DBL_MAX;

      for(int i = 0; i < bars; i++)
        {
         col[b][i] = v[i];

         if(!MathIsValidNumber(v[i]) || v[i] == EMPTY_VALUE || MathAbs(v[i]) > 1.0e300)
           {
            blank[b]++;
            continue;
           }
         if(v[i] == 0.0)
           {
            zero[b]++;
            continue;
           }
         real[b]++;
         if(v[i] < lo[b])
            lo[b] = v[i];
         if(v[i] > hi[b])
            hi[b] = v[i];
        }
      found++;
     }

   if(found == 0)
     {
      //--- say so once every ten seconds and keep trying; a first empty read
      //--- proves nothing while the indicator is still filling
      const uint now = GetTickCount();
      if(g_noDataSaid == 0 || now - g_noDataSaid > 10000)
        {
         g_noDataSaid = now;
         Print("AnyIndicatorAlert: the indicator loaded but returned no buffer data yet.");
         Print("  It will keep looking. If this never fills, the indicator may draw with");
         Print("  chart objects rather than buffers, and this tool cannot read those.");
        }
      return(false);
     }

   Print("");
   PrintFormat("Buffers found: %d   (checked up to %d, on %s %s)", found, probe, _Symbol, EnumToString(g_tf));
   Print("------------------------------------------------------------------");
   PrintFormat("  %6s  %6s %6s %6s  %-38s %s",
               "buffer", "values", "zeros", "blank", "what it looks like", "range of the values");

   bool zeroHint = false;

   for(int b = 0; b < found; b++)
     {
      const double share = (double)real[b] / (double)bars;
      string kind;
      if(real[b] == 0)
         kind = "nothing here on these bars";
      else
         if(share > 0.9)
            kind = "a line - a value on almost every bar";
         else
            kind = "sparse - looks like a signal";

      string range = "-";
      if(real[b] > 0)
         range = StringFormat("%.5f .. %.5f", lo[b], hi[b]);

      PrintFormat("  %6d  %6d %6d %6d  %-38s %s", b, real[b], zero[b], blank[b], kind, range);

      if(!InpZeroIsEmpty && zero[b] * 2 >= bars && real[b] > 0)
         zeroHint = true;
     }

   Print("------------------------------------------------------------------");

   if(found >= probe)
     {
      PrintFormat("Note: it stopped after %d because that is the probe limit, not because", probe);
      Print("the indicator ran out of buffers. Raise 'How many buffers to probe' to see");
      Print("whether there are more.");
      Print("------------------------------------------------------------------");
     }

   if(zeroHint)
     {
      Print("Note: at least one buffer is mostly exact zeros with a few real values.");
      Print("Some indicators write 0 where they mean \"nothing here\" instead of");
      Print("EMPTY_VALUE - ZigZag is one. If that is the case here, switch on");
      Print("'This indicator writes 0 where it means nothing' and read this again.");
      Print("If instead the buffer is an oscillator that genuinely sits at zero,");
      Print("leave it off. From outside the indicator the two look identical, so");
      Print("this tool will not guess for you.");
      Print("------------------------------------------------------------------");
     }

   const int shown = MathMin(found, 8);
   string head = "  bar  time             ";
   for(int b = 0; b < shown; b++)
      head += StringFormat("  buf%-8d", b);
   Print(head);

   datetime t[];
   ArraySetAsSeries(t, true);
   const int gotT = CopyTime(_Symbol, g_tf, 0, bars, t);

   for(int i = 0; i < bars; i++)
     {
      string line = StringFormat("  %3d  %-16s ", i,
                                 (i < gotT) ? TimeToString(t[i], TIME_DATE | TIME_MINUTES) : "?");
      for(int b = 0; b < shown; b++)
         line += "  " + Show(col[b][i]);
      Print(line);
     }

   if(found > shown)
      PrintFormat("  (%d more buffer(s) exist and are summarised above but not in the table)", found - shown);

   Print("------------------------------------------------------------------");
   Print("Read it like this: the buffer that is empty on most bars and carries a value");
   Print("only where the indicator drew its signal is the one to watch. Put its number");
   Print("in 'Buffer to watch', set Mode to WATCH, and pick a trigger.");
   Print("A buffer that has a value on every bar is a line - use a level or buffer cross.");
   Print("");

   Comment(StringFormat("AnyIndicatorAlert - EXPLORE\n%s on %s\n%d buffer(s) found - see the Experts log",
                        InpIndicator, EnumToString(g_tf), found));
   return(true);
  }

//+------------------------------------------------------------------+
//| Deliver an alert                                                  |
//+------------------------------------------------------------------+
void Fire(const string what)
  {
   const string msg = StringFormat("%s %s: %s", _Symbol, EnumToString(g_tf), what);

   Print("ALERT  " + msg);
   if(InpPopup)
      Alert(msg);
   if(InpSound)
      PlaySound(InpSoundFile);
   if(InpPush)
      SendNotification(msg);
   if(InpEmail)
      SendMail("AnyIndicatorAlert", msg);
  }

//+------------------------------------------------------------------+
//| Snapshot bookkeeping for the repaint check                        |
//+------------------------------------------------------------------+
int FindSnap(const datetime when)
  {
   const int n = ArraySize(g_snapT);
   for(int i = 0; i < n; i++)
      if(g_snapT[i] == when)
         return(i);
   return(-1);
  }

void AddSnap(const datetime when, const double v)
  {
   const int n = ArraySize(g_snapT);
   ArrayResize(g_snapT, n + 1);
   ArrayResize(g_snapV, n + 1);
   g_snapT[n] = when;
   g_snapV[n] = v;
  }

//+------------------------------------------------------------------+
//| Re-read the closed bars and compare them with what they held      |
//| last time. Runs once per bar of the watched timeframe.            |
//|                                                                   |
//| A bar going from blank to a value is a LATE VALUE: the indicator  |
//| needed later bars before it could mark this one. Fractals do that |
//| by design and it is not deceit, but it does mean the signal was   |
//| never visible on the bar it points at. A value that moves or      |
//| vanishes is a REPAINT: something you could have acted on is gone. |
//| `report` says whether to print them; the late arrivals are always |
//| collected because the APPEARS trigger needs them.                 |
//+------------------------------------------------------------------+
void SnapshotPass(const bool report)
  {
   g_lateCount = 0;

   //--- never ask for more closed bars than the chart holds, or a freshly
   //--- opened symbol would be checked for nothing until it grew to the window
   int n = MathMin(InpRepaintBars, 500);
   n = MathMin(n, Bars(_Symbol, g_tf) - 1);
   if(n < 2)
      return;

   double v[];
   if(!ReadBuffer(InpBufferA, 1, n, v))
      return;

   datetime t[];
   ArraySetAsSeries(t, true);
   if(CopyTime(_Symbol, g_tf, 1, n, t) != n)
      return;

   for(int i = 0; i < n; i++)
     {
      const int k = FindSnap(t[i]);
      if(k < 0)
        {
         AddSnap(t[i], v[i]);          // first sight of this bar - nothing to compare yet
         continue;
        }
      const double old = g_snapV[k];
      if(!Differs(old, v[i]))
         continue;
      g_snapV[k] = v[i];

      const string when = TimeToString(t[i], TIME_DATE | TIME_MINUTES);

      //--- a bar the indicator has not written yet reads exactly 0.0, because
      //--- that is what the terminal puts in a freshly grown buffer, and a
      //--- lagging indicator leaves its newest bars like that until it has the
      //--- later bars it needs. Going from that 0.0 to blank is initialisation,
      //--- not a change. Going from it to a value is a late arrival, not a move.
      //--- Measured on Examples\Fractals, whose newest three bars always read 0.0.
      const bool oldUnwritten = (!InpZeroIsEmpty && old == 0.0);
      if(oldUnwritten && IsBlank(v[i]))
         continue;

      if((IsBlank(old) || oldUnwritten) && !IsBlank(v[i]))
        {
         //--- i is the bar's distance behind the one that just closed, so it
         //--- is also how many bars late the value arrived
         g_lateTotal++;
         g_lateCount++;
         if(g_lateCount == 1)
           {
            g_lateBar = t[i];
            g_lateAge = i;
            g_lateVal = v[i];
           }
         if(report)
            PrintFormat("LATE VALUE  %s buffer %d  bar %s was filled %d bar(s) after it closed: %s",
                        InpIndicator, InpBufferA, when, i, DoubleToString(v[i], 8));
         continue;
        }

      g_repaints++;
      if(report)
         PrintFormat("REPAINT  %s buffer %d  bar %s %s after the bar closed:  %s  ->  %s",
                     InpIndicator, InpBufferA, when, IsBlank(v[i]) ? "vanished" : "moved",
                     DoubleToString(old, 8),
                     IsBlank(v[i]) ? "(empty)" : DoubleToString(v[i], 8));
     }

   //--- forget bars that have fallen out of the window
   const datetime oldest = t[n - 1];
   for(int i = ArraySize(g_snapT) - 1; i >= 0; i--)
     {
      if(g_snapT[i] >= oldest)
         continue;
      const int last = ArraySize(g_snapT) - 1;
      g_snapT[i] = g_snapT[last];
      g_snapV[i] = g_snapV[last];
      ArrayResize(g_snapT, last);
      ArrayResize(g_snapV, last);
     }
  }

//+------------------------------------------------------------------+
//| WATCH - evaluate the trigger on the newest judged bar.            |
//| Called once per bar when judging closed bars, on every tick when  |
//| judging the forming bar; either way it fires at most once per bar. |
//+------------------------------------------------------------------+
void Watch(const datetime barTime)
  {
   const int startPos = InpClosedBarOnly ? 1 : 0;

   double a[];
   ResetLastError();
   if(!ReadBuffer(InpBufferA, startPos, 2, a))
     {
      //--- said once per episode; a wrong buffer number otherwise fails in silence
      if(!g_readWarned)
        {
         g_readWarned = true;
         PrintFormat("AnyIndicatorAlert: cannot read buffer %d of \"%s\" (error %d).",
                     InpBufferA, InpIndicator, GetLastError());
         Print("  If this persists, that buffer does not exist. Run EXPLORE to see which ones do.");
        }
      return;
     }
   g_readWarned = false;

   const double cur  = a[0];
   const double prev = a[1];

   bool hit = false;
   string what = "";

   switch(InpTrigger)
     {
      case TRIG_APPEARS:
         //--- the plain case: the newest judged bar has a value and the one before did not.
         //--- An exact 0.0 is not taken as a value here: a signal buffer never means
         //--- 0.0, and it is what an unwritten bar reads as (see SnapshotPass)
         if(g_seeded && IsBlank(prev) && !IsBlank(cur) && cur != 0.0)
           {
            hit = true;
            what = StringFormat("%s buffer %d produced a value (%.5f)", InpIndicator, InpBufferA, cur);
           }
         //--- the lagging case: a value arrived on a bar that had already closed blank.
         //--- Fractals and most swing markers work this way, so without this branch
         //--- they would never alert at all
         else
            if(g_lateCount > 0)
              {
               hit = true;
               what = StringFormat("%s buffer %d filled bar %s, %d bar(s) after it closed (%.5f)%s",
                                   InpIndicator, InpBufferA,
                                   TimeToString(g_lateBar, TIME_DATE | TIME_MINUTES),
                                   g_lateAge, g_lateVal,
                                   g_lateCount > 1 ? StringFormat(" and %d more", g_lateCount - 1) : "");
              }
         break;

      case TRIG_CROSS_UP:
         if(!IsBlank(prev) && !IsBlank(cur) && prev < InpLevel && cur >= InpLevel)
           {
            hit = true;
            what = StringFormat("%s buffer %d crossed above %.5f (now %.5f)", InpIndicator, InpBufferA, InpLevel, cur);
           }
         break;

      case TRIG_CROSS_DOWN:
         if(!IsBlank(prev) && !IsBlank(cur) && prev > InpLevel && cur <= InpLevel)
           {
            hit = true;
            what = StringFormat("%s buffer %d crossed below %.5f (now %.5f)", InpIndicator, InpBufferA, InpLevel, cur);
           }
         break;

      case TRIG_BUF_CROSS_UP:
      case TRIG_BUF_CROSS_DN:
        {
         double b[];
         if(!ReadBuffer(InpBufferB, startPos, 2, b))
            return;
         if(IsBlank(prev) || IsBlank(cur) || IsBlank(b[0]) || IsBlank(b[1]))
            break;
         if(InpTrigger == TRIG_BUF_CROSS_UP && prev <= b[1] && cur > b[0])
           {
            hit = true;
            what = StringFormat("%s buffer %d crossed above buffer %d (%.5f vs %.5f)",
                                InpIndicator, InpBufferA, InpBufferB, cur, b[0]);
           }
         if(InpTrigger == TRIG_BUF_CROSS_DN && prev >= b[1] && cur < b[0])
           {
            hit = true;
            what = StringFormat("%s buffer %d crossed below buffer %d (%.5f vs %.5f)",
                                InpIndicator, InpBufferA, InpBufferB, cur, b[0]);
           }
        }
      break;

      case TRIG_CHANGED:
         if(g_seeded && Differs(prev, cur))
           {
            hit = true;
            what = StringFormat("%s buffer %d changed: %s -> %s", InpIndicator, InpBufferA,
                                IsBlank(prev) ? "(empty)" : DoubleToString(prev, 5),
                                IsBlank(cur)  ? "(empty)" : DoubleToString(cur, 5));
           }
         break;
     }

   if(hit && g_alerted != barTime)
     {
      g_alerted = barTime;
      Fire(what);
     }

   g_seeded    = true;
   g_lateCount = 0;                     // consumed; the next pass will refill it

   Comment(StringFormat("AnyIndicatorAlert - WATCH\n%s  buffer %d  %s\nlast value: %s\nlate values: %d   repaints: %d",
                        InpIndicator, InpBufferA, EnumToString(InpTrigger),
                        IsBlank(cur) ? "(empty)" : DoubleToString(cur, 5), g_lateTotal, g_repaints));
  }

//+------------------------------------------------------------------+
//| Keep buffer 0 in step with the watched buffer.                     |
//| Only when the watched timeframe is the chart's own - mapping a     |
//| higher timeframe onto every chart bar is a different job and is    |
//| not attempted here.                                                |
//+------------------------------------------------------------------+
void MirrorBuffer(const int rates_total, const int prev_calculated)
  {
   if(g_tf != (ENUM_TIMEFRAMES)Period())
      return;

   const int need = (prev_calculated <= 0) ? rates_total : MathMin(rates_total, 3);

   //--- on a fresh calculation start clean, so bars the watched indicator
   //--- does not cover read as empty rather than as whatever was there before
   if(prev_calculated <= 0)
      ArrayInitialize(BufOut, EMPTY_VALUE);

   double v[];
   const int got = CopyBuffer(g_handle, InpBufferA, 0, need, v);
   if(got <= 0)
      return;

   for(int i = 0; i < got; i++)
      BufOut[rates_total - got + i] = v[i];
  }

//+------------------------------------------------------------------+
//| Main                                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   //--- the watched indicator could not be loaded yet. Keep the tool on the
   //--- chart and try again every few seconds, so fixing a typo or compiling
   //--- the target is enough - nothing has to be re-attached.
   if(g_handle == INVALID_HANDLE)
     {
      const uint now = GetTickCount();
      if(now - g_retryAt >= 5000)
        {
         g_retryAt = now;
         TryLoad();
        }
      return(rates_total);
     }

   //--- the indicator may still be calculating; a first empty read proves nothing.
   //--- Asking for a value is also what makes a handle on another timeframe
   //--- calculate at all - a handle nobody reads is never computed, so a gate
   //--- on BarsCalculated alone waited forever on H4 (measured in the tester)
   double probe[];
   if(CopyBuffer(g_handle, 0, 0, 1, probe) < 1)
     {
      const uint now = GetTickCount();
      if(now - g_waitSaid > 10000)
        {
         g_waitSaid = now;
         PrintFormat("AnyIndicatorAlert: still waiting for \"%s\" to calculate (%d s so far).",
                     InpIndicator, (int)((now - g_waitFrom) / 1000));
        }
      return(rates_total);
     }

   MirrorBuffer(rates_total, prev_calculated);

   //--- EXPLORE runs once, as soon as there is something to look at
   if(InpMode == MODE_EXPLORE)
     {
      if(!g_explored)
         g_explored = Explore();      // stays false, and is retried, until a table is printed
      return(rates_total);
     }

   //--- WATCH: the repaint check runs once per bar of the watched timeframe;
   //--- the trigger runs once per bar on closed bars, every tick otherwise
   const datetime barTime = (datetime)SeriesInfoInteger(_Symbol, g_tf, SERIES_LASTBAR_DATE);
   if(barTime == 0)
      return(rates_total);

   const bool newBar = (barTime != g_lastBar);
   if(newBar)
     {
      g_lastBar = barTime;
      if(InpRepaintCheck || InpTrigger == TRIG_APPEARS)
         SnapshotPass(InpRepaintCheck);
     }

   if(InpClosedBarOnly && !newBar)
      return(rates_total);

   Watch(barTime);

   return(rates_total);
  }
//+------------------------------------------------------------------+
