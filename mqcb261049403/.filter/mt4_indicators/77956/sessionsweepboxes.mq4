//+------------------------------------------------------------------+
//|                                            SessionSweepBoxes.mq4 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Draws Asian, London and New York session range boxes and marks"
#property description "liquidity sweeps: a closed bar that wicks beyond a completed"
#property description "session's high or low and then closes back inside that level."
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  2

enum ENUM_GMT_MODE
  {
   GMT_MODE_AUTO   = 0, // Auto-detect from server time
   GMT_MODE_MANUAL = 1  // Use manual offset
  };

input string        InpHdrTime         = "===== Time =====";  // .
input ENUM_GMT_MODE InpGmtMode         = GMT_MODE_AUTO;       // Server GMT offset mode
input double        InpManualGmtOffset = 2.0;                 // Manual server GMT offset (hours)
input int           InpLookbackDays    = 20;                  // Days of history to draw

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string InpHdrSess     = "===== Sessions (GMT, HH:MM) ====="; // .
input bool   InpShowAsia    = true;               // Show Asian session
input string InpAsiaStart   = "00:00";            // Asian start
input string InpAsiaEnd     = "08:00";            // Asian end
input color  InpAsiaColor   = clrMediumSlateBlue; // Asian color
input bool   InpShowLondon  = true;               // Show London session
input string InpLondonStart = "07:00";            // London start
input string InpLondonEnd   = "16:00";            // London end
input color  InpLondonColor = clrSeaGreen;        // London color
input bool   InpShowNY      = true;               // Show New York session
input string InpNYStart     = "12:00";            // New York start
input string InpNYEnd       = "21:00";            // New York end
input color  InpNYColor     = clrDarkOrange;      // New York color

input string InpHdrDisp     = "===== Display =====";  // .
input bool   InpFillBoxes   = false; // Fill session boxes
input bool   InpShowLabels  = true;  // Show session name labels
input bool   InpShowLevels  = true;  // Extend completed session high/low lines
input double InpArrowGapATR = 0.3;   // Arrow distance from bar (x ATR)

input string InpHdrSweep         = "===== Sweep detection =====";  // .
input bool   InpOneSweepPerLevel = true; // Mark only the first sweep of each level
input bool   InpCancelOnBreak    = true; // Cancel a level after a bar closes beyond it

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string InpHdrAlert   = "===== Alerts (closed bars only) =====";  // .
input bool   InpAlertPopup = false;       // Pop-up alert
input bool   InpAlertPush  = false;       // Push notification
input bool   InpAlertSound = false;       // Play sound
input string InpSoundFile  = "alert.wav"; // Sound file

//--- buffers
double BufHigh[];
double BufLow[];

//--- per-session state
struct SessionState
  {
   string            name;
   bool              enabled;
   int               startMin;
   int               endMin;
   color             clr;
   bool              building;
   datetime          key;
   datetime          t0;
   datetime          tLast;
   double            hi;
   double            lo;
   bool              hasLevels;
   datetime          lvKey;
   datetime          lvFrom;
   double            lvHi;
   double            lvLo;
   datetime          hiEnd;      // 0 = level still active
   datetime          loEnd;      // 0 = level still active
  };

SessionState g_s[3];

const string PFX = "SSB_";
int      g_offsetSec   = 0;
int      g_periodSec   = 0;
datetime g_firstTime   = 0;
datetime g_lastBarTime = 0;
bool     g_tfOk        = true;

//+------------------------------------------------------------------+
int OnInit()
  {
   g_tfOk = (PeriodSeconds() <= 3600);
   if(!g_tfOk)
      Print("Session Sweep Boxes: switch to H1 or a lower timeframe.");

   if(!SetupSession(0, "Asia",     InpShowAsia,   InpAsiaStart,   InpAsiaEnd,   InpAsiaColor)   ||
      !SetupSession(1, "London",   InpShowLondon, InpLondonStart, InpLondonEnd, InpLondonColor) ||
      !SetupSession(2, "New York", InpShowNY,     InpNYStart,     InpNYEnd,     InpNYColor))
      return(INIT_PARAMETERS_INCORRECT);

   if(InpLookbackDays < 1)
     {
      Print("Days of history to draw must be 1 or more.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_offsetSec = DetectOffset();
   g_periodSec = PeriodSeconds();
   PrintFormat("Session Sweep Boxes: server GMT offset %+.1f h", g_offsetSec / 3600.0);

   SetIndexBuffer(0, BufHigh);
   SetIndexBuffer(1, BufLow);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexArrow(1, 233);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexLabel(0, "Session High Sweep");
   SetIndexLabel(1, "Session Low Sweep");

   IndicatorShortName("Session Sweep Boxes");
   IndicatorDigits(Digits);

   DeleteObjects();
   g_lastBarTime = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects();
   ChartRedraw();
  }

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
   if(!g_tfOk || rates_total < 3)
      return(rates_total);

   ArraySetAsSeries(time,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);

   bool newBar = (prev_calculated == 0 || time[0] != g_lastBarTime);
   if(newBar)
     {
      FullPass(rates_total, time, high, low, close, prev_calculated > 0);
      g_lastBarTime = time[0];
     }

   LiveUpdate(time, high, low);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Recalculate all closed bars inside the lookback window           |
//| (series indexing: 0 = forming bar, 1 = last closed bar)          |
//+------------------------------------------------------------------+
void FullPass(const int total, const datetime &time[], const double &high[],
              const double &low[], const double &close[], const bool allowAlerts)
  {
   ArrayInitialize(BufHigh, EMPTY_VALUE);
   ArrayInitialize(BufLow,  EMPTY_VALUE);
   ResetStates();

   datetime from = time[0] - InpLookbackDays * 86400;
   int first = total - 1;
   for(int k = 1; k < total; k++)
      if(time[k] < from)
        {
         first = k - 1;
         break;
        }
   if(first < 1)
      first = 1;
   g_firstTime = time[first];

   for(int i = first; i >= 1; i--)
      for(int s = 0; s < 3; s++)
         if(g_s[s].enabled)
            ProcessBar(s, i, time, high, low, close, allowAlerts && i == 1);

   datetime nowEnd = time[0] + g_periodSec;
   for(int s = 0; s < 3; s++)
     {
      if(!g_s[s].enabled)
         continue;
      if(g_s[s].building)
         DrawBox(s, g_s[s].key, g_s[s].t0, g_s[s].tLast + g_periodSec, g_s[s].hi, g_s[s].lo);
      DrawLevels(s, nowEnd);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
void ProcessBar(const int s, const int i, const datetime &time[], const double &high[],
                const double &low[], const double &close[], const bool alertBar)
  {
   datetime key = 0;
   if(InSession(s, time[i], key))
     {
      if(key < g_firstTime)                // instance started before the window
         return;

      if(!g_s[s].building || g_s[s].key != key)
        {
         if(g_s[s].building)
            FinalizeSession(s);
         RetireLevels(s, time[i]);
         g_s[s].building = true;
         g_s[s].key      = key;
         g_s[s].t0       = time[i];
         g_s[s].tLast    = time[i];
         g_s[s].hi       = high[i];
         g_s[s].lo       = low[i];
        }
      else
        {
         g_s[s].tLast = time[i];
         if(high[i] > g_s[s].hi)
            g_s[s].hi = high[i];
         if(low[i]  < g_s[s].lo)
            g_s[s].lo = low[i];
        }
      return;
     }

   if(g_s[s].building)
      FinalizeSession(s);

   CheckSweep(s, i, time, high, low, close, alertBar);
  }

//+------------------------------------------------------------------+
void CheckSweep(const int s, const int i, const datetime &time[], const double &high[],
                const double &low[], const double &close[], const bool alertBar)
  {
   if(!g_s[s].hasLevels)
      return;

   double gap = iATR(NULL, 0, 14, i) * InpArrowGapATR;

//--- session high
   if(g_s[s].hiEnd == 0 && high[i] > g_s[s].lvHi)
     {
      if(close[i] < g_s[s].lvHi)
        {
         BufHigh[i] = high[i] + gap;
         if(InpOneSweepPerLevel)
            g_s[s].hiEnd = time[i] + g_periodSec;
         if(alertBar)
            NotifySweep(s, true, g_s[s].lvHi);
        }
      else
         if(InpCancelOnBreak)
            g_s[s].hiEnd = time[i] + g_periodSec;
     }

//--- session low
   if(g_s[s].loEnd == 0 && low[i] < g_s[s].lvLo)
     {
      if(close[i] > g_s[s].lvLo)
        {
         BufLow[i] = low[i] - gap;
         if(InpOneSweepPerLevel)
            g_s[s].loEnd = time[i] + g_periodSec;
         if(alertBar)
            NotifySweep(s, false, g_s[s].lvLo);
        }
      else
         if(InpCancelOnBreak)
            g_s[s].loEnd = time[i] + g_periodSec;
     }
  }

//+------------------------------------------------------------------+
//| Update the forming bar on every tick (boxes and lines only)      |
//+------------------------------------------------------------------+
void LiveUpdate(const datetime &time[], const double &high[], const double &low[])
  {
   datetime nowEnd = time[0] + g_periodSec;

   for(int s = 0; s < 3; s++)
     {
      if(!g_s[s].enabled)
         continue;

      datetime key = 0;
      bool newInstance = false;
      if(InSession(s, time[0], key) && key >= g_firstTime)
        {
         if(g_s[s].building && g_s[s].key == key)
            DrawBox(s, key, g_s[s].t0, nowEnd,
                    MathMax(g_s[s].hi, high[0]), MathMin(g_s[s].lo, low[0]));
         else
           {
            DrawBox(s, key, time[0], nowEnd, high[0], low[0]);
            newInstance = true;
           }
        }
      DrawLevels(s, newInstance ? time[0] : nowEnd);
     }
  }

//+------------------------------------------------------------------+
void FinalizeSession(const int s)
  {
   DrawBox(s, g_s[s].key, g_s[s].t0, g_s[s].tLast + g_periodSec, g_s[s].hi, g_s[s].lo);
   g_s[s].building  = false;
   g_s[s].hasLevels = true;
   g_s[s].lvKey     = g_s[s].key;
   g_s[s].lvFrom    = g_s[s].tLast + g_periodSec;
   g_s[s].lvHi      = g_s[s].hi;
   g_s[s].lvLo      = g_s[s].lo;
   g_s[s].hiEnd     = 0;
   g_s[s].loEnd     = 0;
  }

//+------------------------------------------------------------------+
void RetireLevels(const int s, const datetime t)
  {
   if(!g_s[s].hasLevels)
      return;
   if(g_s[s].hiEnd == 0)
      g_s[s].hiEnd = t;
   if(g_s[s].loEnd == 0)
      g_s[s].loEnd = t;
   DrawLevels(s, t);
   g_s[s].hasLevels = false;
  }

//+------------------------------------------------------------------+
void ResetStates()
  {
   for(int s = 0; s < 3; s++)
     {
      g_s[s].building  = false;
      g_s[s].hasLevels = false;
      g_s[s].key       = 0;
      g_s[s].hiEnd     = 0;
      g_s[s].loEnd     = 0;
     }
  }

//+------------------------------------------------------------------+
//| Is a bar inside session s? Returns the session instance key      |
//+------------------------------------------------------------------+
bool InSession(const int s, const datetime t, datetime &key)
  {
   long g   = (long)t - g_offsetSec;
   long day = g - (g % 86400);
   int  m   = (int)((g % 86400) / 60);
   int  st  = g_s[s].startMin;
   int  en  = g_s[s].endMin;
   bool in;

   if(st < en)
      in = (m >= st && m < en);
   else
     {
      in = (m >= st || m < en);
      if(m < en)
         day -= 86400;
     }
   if(!in)
      return(false);

   key = (datetime)(day + (long)st * 60);
   return(true);
  }

//+------------------------------------------------------------------+
bool SetupSession(const int s, const string name, const bool on,
                  const string startTxt, const string endTxt, const color c)
  {
   g_s[s].name     = name;
   g_s[s].enabled  = on;
   g_s[s].clr      = c;
   g_s[s].startMin = ParseHM(startTxt);
   g_s[s].endMin   = ParseHM(endTxt);
   if(!on)
      return(true);
   if(g_s[s].startMin < 0 || g_s[s].endMin < 0 || g_s[s].startMin == g_s[s].endMin)
     {
      PrintFormat("Invalid %s session times: %s - %s (use HH:MM)", name, startTxt, endTxt);
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
int ParseHM(const string txt)
  {
   string parts[];
   if(StringSplit(txt, ':', parts) != 2)
      return(-1);
   int h = (int)StringToInteger(parts[0]);
   int m = (int)StringToInteger(parts[1]);
   if(h < 0 || h > 23 || m < 0 || m > 59)
      return(-1);
   return(h * 60 + m);
  }

//+------------------------------------------------------------------+
//| Server GMT offset. Auto mode needs a live market: over the       |
//| weekend the last server time is stale, so the manual value is    |
//| used instead.                                                    |
//+------------------------------------------------------------------+
int DetectOffset()
  {
   int manual = (int)MathRound(InpManualGmtOffset * 3600.0);
   if(InpGmtMode == GMT_MODE_MANUAL)
      return(manual);
   if(IsTesting())
     {
      Print("Strategy Tester: auto GMT offset is not available, using the manual offset.");
      return(manual);
     }

   datetime gmt = TimeGMT();
   int dow  = TimeDayOfWeek(gmt);
   int hour = TimeHour(gmt);
   bool weekend = (dow == 6) || (dow == 0 && hour < 22) || (dow == 5 && hour >= 21);
   if(weekend)
     {
      Print("Market closed: auto GMT offset unavailable, using the manual offset.");
      return(manual);
     }

   long diff = (long)TimeCurrent() - (long)gmt;
   int  sec  = (int)(MathRound(diff / 1800.0) * 1800);
   if(MathAbs(sec) > 14 * 3600)
     {
      Print("Could not detect the server GMT offset, using the manual offset.");
      return(manual);
     }
   return(sec);
  }

//+------------------------------------------------------------------+
//| Drawing                                                          |
//+------------------------------------------------------------------+
string ObjName(const string kind, const int s, const datetime key)
  {
   return(PFX + kind + "_" + IntegerToString(s) + "_" + IntegerToString((long)key));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetCommon(const string n)
  {
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   for(int k = ObjectsTotal(0, -1, -1) - 1; k >= 0; k--)
     {
      string n = ObjectName(0, k, -1, -1);
      if(StringFind(n, PFX) == 0)
         ObjectDelete(0, n);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBox(const int s, const datetime key, const datetime t1, const datetime t2,
             const double hi, const double lo)
  {
   string n = ObjName("B", s, key);
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_RECTANGLE, 0, t1, hi, t2, lo);
      SetCommon(n);
      ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
     }
   ObjectSetInteger(0, n, OBJPROP_TIME,  0, t1);
   ObjectSetDouble(0,  n, OBJPROP_PRICE, 0, hi);
   ObjectSetInteger(0, n, OBJPROP_TIME,  1, t2);
   ObjectSetDouble(0,  n, OBJPROP_PRICE, 1, lo);
   ObjectSetInteger(0, n, OBJPROP_COLOR, g_s[s].clr);
   ObjectSetInteger(0, n, OBJPROP_BACK,  InpFillBoxes);   // MT4 fills background rectangles

   if(!InpShowLabels)
      return;

   string tn = ObjName("T", s, key);
   if(ObjectFind(0, tn) < 0)
     {
      ObjectCreate(0, tn, OBJ_TEXT, 0, t1, hi);
      SetCommon(tn);
      ObjectSetString(0,  tn, OBJPROP_TEXT,     g_s[s].name);
      ObjectSetString(0,  tn, OBJPROP_FONT,     "Arial");
      ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, tn, OBJPROP_ANCHOR,   ANCHOR_LEFT_LOWER);
     }
   ObjectSetInteger(0, tn, OBJPROP_TIME,  0, t1);
   ObjectSetDouble(0,  tn, OBJPROP_PRICE, 0, hi);
   ObjectSetInteger(0, tn, OBJPROP_COLOR, g_s[s].clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(const string kind, const int s, const datetime key,
              const datetime t1, const datetime t2, const double p)
  {
   string n = ObjName(kind, s, key);
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_TREND, 0, t1, p, t2, p);
      SetCommon(n);
      ObjectSetInteger(0, n, OBJPROP_RAY,   false);
      ObjectSetInteger(0, n, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
     }
   ObjectSetInteger(0, n, OBJPROP_TIME,  0, t1);
   ObjectSetDouble(0,  n, OBJPROP_PRICE, 0, p);
   ObjectSetInteger(0, n, OBJPROP_TIME,  1, t2);
   ObjectSetDouble(0,  n, OBJPROP_PRICE, 1, p);
   ObjectSetInteger(0, n, OBJPROP_COLOR, g_s[s].clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLevels(const int s, const datetime runningEnd)
  {
   if(!InpShowLevels || !g_s[s].hasLevels)
      return;
   DrawLine("H", s, g_s[s].lvKey, g_s[s].lvFrom,
            (g_s[s].hiEnd > 0 ? g_s[s].hiEnd : runningEnd), g_s[s].lvHi);
   DrawLine("L", s, g_s[s].lvKey, g_s[s].lvFrom,
            (g_s[s].loEnd > 0 ? g_s[s].loEnd : runningEnd), g_s[s].lvLo);
  }

//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void NotifySweep(const int s, const bool isHigh, const double level)
  {
   if(!InpAlertPopup && !InpAlertPush && !InpAlertSound)
      return;
   string tf  = StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7);
   string msg = StringFormat("%s %s: %s %s %s swept (%s)",
                             _Symbol, tf, g_s[s].name, (isHigh ? "high" : "low"),
                             DoubleToString(level, _Digits), (isHigh ? "bearish" : "bullish"));
   if(InpAlertPopup)
      Alert(msg);
   if(InpAlertPush)
      SendNotification(msg);
   if(InpAlertSound)
      PlaySound(InpSoundFile);
  }
//+------------------------------------------------------------------+
