//+------------------------------------------------------------------+
//|                                               SessionHighLow.mq5 |
//|  Draws the Asian, London and New York session ranges as boxes    |
//|  with their high/low, plus optional extension lines for          |
//|  breakout trading. Ranges come from M5 data, so they are the     |
//|  same on every chart timeframe up to the chosen maximum.         |
//+------------------------------------------------------------------+
#property copyright   "Shanawaz M."
#property version     "1.00"
#property description "Session High Low: draws Asian, London and New York session boxes with high/low prices and optional breakout extension lines. Session times are set in broker server time."
#property indicator_chart_window
#property indicator_plots 0

//--- input parameters
input int             InpDays        = 10;              // Number of days to draw
input ENUM_TIMEFRAMES InpMaxTF       = PERIOD_H1;       // Hide on timeframes above
input bool            InpShowLabels  = true;            // Show session names and prices
input int             InpExtendHours = 4;               // Extend high/low lines after session end, hours (0 = off)

input group "Asian session (server time)"
input bool            InpAsiaOn      = true;            // Show Asian session
input string          InpAsiaStart   = "02:00";         // Start, HH:MM
input string          InpAsiaEnd     = "10:00";         // End, HH:MM
input color           InpAsiaColor   = C'215,230,250';  // Box color

input group "London session (server time)"
input bool            InpLondonOn    = true;            // Show London session
input string          InpLondonStart = "10:00";         // Start, HH:MM
input string          InpLondonEnd   = "18:00";         // End, HH:MM
input color           InpLondonColor = C'220,242,220';  // Box color

input group "New York session (server time)"
input bool            InpNYOn        = true;            // Show New York session
input string          InpNYStart     = "15:00";         // Start, HH:MM
input string          InpNYEnd       = "23:00";         // End, HH:MM
input color           InpNYColor     = C'252,228,212';  // Box color

#define PREFIX "SHL_"

//--- one session definition
struct SSession
  {
   string            name;
   bool              enabled;
   int               start_sec;
   int               end_sec;
   color             clr;
  };

SSession g_sessions[3];
datetime g_last_bar  = 0;
bool     g_need_more = false;

//+------------------------------------------------------------------+
//| Convert "HH:MM" to seconds after midnight, -1 on error           |
//+------------------------------------------------------------------+
int ParseHHMM(const string text)
  {
   string parts[];
   if(StringSplit(text, ':', parts) != 2)
      return(-1);
   int h = (int)StringToInteger(parts[0]);
   int m = (int)StringToInteger(parts[1]);
   if(h < 0 || h > 23 || m < 0 || m > 59)
      return(-1);
   return(h * 3600 + m * 60);
  }

//+------------------------------------------------------------------+
//| Fill one session definition, returns false on a bad time         |
//+------------------------------------------------------------------+
bool SetSession(const int i, const string name, const bool on, const string start, const string end, const color clr)
  {
   g_sessions[i].name      = name;
   g_sessions[i].enabled   = on;
   g_sessions[i].start_sec = ParseHHMM(start);
   g_sessions[i].end_sec   = ParseHHMM(end);
   g_sessions[i].clr       = clr;
   if(on && (g_sessions[i].start_sec < 0 || g_sessions[i].end_sec < 0))
     {
      PrintFormat("%s session: use HH:MM format, got '%s' - '%s'", name, start, end);
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDays < 1 || InpDays > 200)
      return(INIT_PARAMETERS_INCORRECT);
   if(!SetSession(0, "Asia", InpAsiaOn, InpAsiaStart, InpAsiaEnd, InpAsiaColor) ||
      !SetSession(1, "London", InpLondonOn, InpLondonStart, InpLondonEnd, InpLondonColor) ||
      !SetSession(2, "New York", InpNYOn, InpNYStart, InpNYEnd, InpNYColor))
      return(INIT_PARAMETERS_INCORRECT);

//--- the timer redraws once M5 history has finished loading
   EventSetTimer(5);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- hidden on higher timeframes: do not request any M5 history there
   if(_Period > InpMaxTF)
     {
      if(prev_calculated == 0)
         DrawAll();                            // clears old objects
      return(rates_total);
     }
//--- redraw on the first call and on every new M5 bar (keeps the live session box growing)
   datetime m5_bar = iTime(_Symbol, PERIOD_M5, 0);
   if(prev_calculated == 0 || m5_bar != g_last_bar)
     {
      g_last_bar = m5_bar;
      DrawAll();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer: retry while history is still loading                      |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_need_more)
      DrawAll();
  }

//+------------------------------------------------------------------+
//| Draw all sessions for the last InpDays days                      |
//+------------------------------------------------------------------+
void DrawAll()
  {
   ObjectsDeleteAll(0, PREFIX);
   g_need_more = false;

   if(_Period > InpMaxTF)
     {
      ChartRedraw();
      return;
     }

   datetime now = TimeCurrent();
   for(int d = 0; d < InpDays; d++)
     {
      //--- D1 bars exist only for trading days, so weekends are skipped automatically
      datetime day = iTime(_Symbol, PERIOD_D1, d);
      if(day == 0)
        {
         g_need_more = true;
         break;
        }
      for(int s = 0; s < 3; s++)
         if(g_sessions[s].enabled)
            DrawSession(g_sessions[s], day, now);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw one session box for one day                                 |
//+------------------------------------------------------------------+
void DrawSession(const SSession &sess, const datetime day, const datetime now)
  {
   datetime start = day + sess.start_sec;
   datetime end   = day + sess.end_sec;
   if(sess.end_sec <= sess.start_sec)
      end += 86400;          // session crosses midnight
   if(start > now)
      return;                // not started yet

   datetime last = (end < now) ? end - 1 : now;
   double highs[], lows[];
   int n_hi = CopyHigh(_Symbol, PERIOD_M5, start, last, highs);
   int n_lo = CopyLow(_Symbol, PERIOD_M5, start, last, lows);
   if(n_hi < 0 || n_lo < 0)
     {
      g_need_more = true;    // history not ready yet
      return;
     }
   if(n_hi == 0 || n_lo == 0)
      return;                // no trading in this session (holiday)

   double hi = highs[ArrayMaximum(highs)];
   double lo = lows[ArrayMinimum(lows)];
   string id = PREFIX + sess.name + "_" + TimeToString(day, TIME_DATE);

//--- filled box from session start to session end
   ObjectCreate(0, id + "_box", OBJ_RECTANGLE, 0, start, hi, end, lo);
   ObjectSetInteger(0, id + "_box", OBJPROP_COLOR, sess.clr);
   ObjectSetInteger(0, id + "_box", OBJPROP_FILL, true);
   ObjectSetInteger(0, id + "_box", OBJPROP_BACK, true);
   ObjectSetInteger(0, id + "_box", OBJPROP_SELECTABLE, false);
   ObjectSetString(0, id + "_box", OBJPROP_TOOLTIP,
                   StringFormat("%s  H %s  L %s  (%d points)", sess.name,
                                DoubleToString(hi, _Digits), DoubleToString(lo, _Digits),
                                (int)MathRound((hi - lo) / _Point)));

//--- breakout extension lines after the session closes
   if(InpExtendHours > 0 && end <= now)
     {
      datetime ext_end = end + InpExtendHours * 3600;
      DrawLevel(id + "_hi", end, ext_end, hi);
      DrawLevel(id + "_lo", end, ext_end, lo);
     }

   if(InpShowLabels)
     {
      string text = StringFormat("%s %s / %s", sess.name, DoubleToString(hi, _Digits), DoubleToString(lo, _Digits));
      //--- New York overlaps London, so put its label under the box to avoid collisions
      bool below = (sess.name == "New York");
      ObjectCreate(0, id + "_lbl", OBJ_TEXT, 0, start, below ? lo : hi);
      ObjectSetString(0, id + "_lbl", OBJPROP_TEXT, text);
      ObjectSetInteger(0, id + "_lbl", OBJPROP_ANCHOR, below ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, id + "_lbl", OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0, id + "_lbl", OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, id + "_lbl", OBJPROP_SELECTABLE, false);
     }
  }

//+------------------------------------------------------------------+
//| Dotted horizontal segment for a session high or low              |
//+------------------------------------------------------------------+
void DrawLevel(const string name, const datetime from, const datetime to, const double price)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, from, price, to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }
//+------------------------------------------------------------------+
