//+------------------------------------------------------------------+
//|                                               SessionHighLow.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Draws the highest high and lowest low reached during a "
#property description "user-defined intraday session (e.g. Asian, London, New York) "
#property description "as horizontal price lines or a rectangular box on the chart."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- display mode selector
enum ENUM_DISPLAY_MODE
  {
   MODE_LINES = 0,   // Horizontal High/Low lines
   MODE_BOX   = 1    // Rectangle box
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Session Time Settings (Broker/Server Time) ==="
input int    InpSessionStartHour   = 8;             // Session Start Hour   (0-23)
input int    InpSessionStartMinute = 0;              // Session Start Minute (0-59)
input int    InpSessionEndHour     = 16;             // Session End Hour     (0-23)
input int    InpSessionEndMinute   = 0;              // Session End Minute   (0-59)

input group "=== History Settings ==="
input int    InpSessionsToShow     = 10;             // Number of Past Sessions to Display

input group "=== Display Settings ==="
input ENUM_DISPLAY_MODE InpDisplayMode      = MODE_BOX;     // Display Mode
input color              InpHighLineColor   = clrLime;      // High Line Color
input color              InpLowLineColor    = clrRed;       // Low Line Color
input color              InpBoxColor        = clrDodgerBlue;// Box Border/Fill Color
input ENUM_LINE_STYLE     InpLineStyle       = STYLE_DASH;   // Line Style
input int                 InpLineWidth       = 1;            // Line Width
input bool                InpShowLabels      = true;         // Show High/Low Price Labels
input bool                InpExtendCurrentSession = true;    // Extend Unfinished Session To Current Time

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string   g_ObjPrefix = "SessHL_";     // unique prefix for all objects created by this indicator
int      g_StartSec  = 0;             // session start, seconds from midnight
int      g_EndSec    = 0;             // session end,   seconds from midnight
int      g_DurationSec = 0;           // session duration in seconds
datetime g_LastBarTime = 0;           // time of the last processed bar (used to detect a new bar)
datetime g_CurSessionStart = 0;       // start time of the currently forming (last) session
datetime g_CurSessionEnd   = 0;       // end time of the currently forming (last) session

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate user input to avoid an invalid or zero-length session
   if(InpSessionStartHour < 0 || InpSessionStartHour > 23 ||
      InpSessionEndHour   < 0 || InpSessionEndHour   > 23 ||
      InpSessionStartMinute < 0 || InpSessionStartMinute > 59 ||
      InpSessionEndMinute   < 0 || InpSessionEndMinute   > 59)
     {
      Alert("SessionHighLow: invalid hour/minute input, please use 0-23 / 0-59.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpSessionsToShow <= 0)
     {
      Alert("SessionHighLow: 'Sessions To Show' must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- pre-calculate the session window in seconds-from-midnight, once, for speed
   g_StartSec = InpSessionStartHour * 3600 + InpSessionStartMinute * 60;
   g_EndSec   = InpSessionEndHour   * 3600 + InpSessionEndMinute   * 60;

   g_DurationSec = g_EndSec - g_StartSec;
   if(g_DurationSec <= 0)
      g_DurationSec += 86400; // handles overnight sessions, e.g. 23:00 -> 08:00

//--- give the indicator a readable name in the Data Window / object list
   IndicatorSetString(INDICATOR_SHORTNAME, "Session High-Low");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove every chart object this indicator has created, identified by its unique prefix
   ObjectsDeleteAll(0, g_ObjPrefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                             |
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
   if(rates_total < 2)
      return(0);

//--- detect whether a brand-new bar has opened since the previous call
   bool isNewBar = (time[rates_total - 1] != g_LastBarTime);

   if(prev_calculated == 0 || isNewBar)
     {
      //--- full rebuild: happens only on indicator start or once per new bar,
      //--- keeping OnCalculate lightweight on every other (intra-bar) tick
      g_LastBarTime = time[rates_total - 1];
      RebuildAllSessions(time, high, low, rates_total);
     }
   else
     {
      //--- intra-bar tick: only refresh the still-forming (most recent) session,
      //--- avoiding a full historical rescan and object redraw
      UpdateOngoingSession(time, high, low, rates_total);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Returns the start-of-day (00:00) timestamp for a given time      |
//+------------------------------------------------------------------+
datetime TimeOfDayStart(const datetime t)
  {
   return(t - (t % 86400));
  }

//+------------------------------------------------------------------+
//| Scans bars in [sessStart, sessEnd) and returns high/low          |
//| Returns the number of bars found inside the session window       |
//+------------------------------------------------------------------+
int GetSessionHighLow(const datetime &time[], const double &high[], const double &low[],
                       const int rates_total, const datetime sessStart, const datetime sessEnd,
                       double &outHigh, double &outLow)
  {
   int    count   = 0;
   double sHigh   = -DBL_MAX;
   double sLow    = DBL_MAX;

   for(int i = rates_total - 1; i >= 0; i--)
     {
      if(time[i] < sessStart)
         break;                        // array is time-ascending; nothing older can match
      if(time[i] >= sessEnd)
         continue;                     // bar belongs to a later session, keep scanning back

      if(high[i] > sHigh) sHigh = high[i];
      if(low[i]  < sLow)  sLow  = low[i];
      count++;
     }

   outHigh = sHigh;
   outLow  = sLow;
   return(count);
  }

//+------------------------------------------------------------------+
//| Rebuilds every visible session box/line from scratch             |
//+------------------------------------------------------------------+
void RebuildAllSessions(const datetime &time[], const double &high[], const double &low[], const int rates_total)
  {
   ObjectsDeleteAll(0, g_ObjPrefix);

   datetime firstBarTime = time[0];
   datetime lastBarTime  = time[rates_total - 1];
   datetime todayBase    = TimeOfDayStart(lastBarTime);

   int collected = 0;

   //--- walk backwards day by day until we have InpSessionsToShow sessions,
   //--- or we run out of available history
   for(int d = 0; collected < InpSessionsToShow; d++)
     {
      datetime dayBase   = todayBase - (datetime)d * 86400;
      datetime sessStart = dayBase + g_StartSec;
      datetime sessEnd   = sessStart + g_DurationSec;

      //--- stop once the session window starts entirely before all loaded history
      if(sessEnd < firstBarTime)
         break;

      //--- skip sessions that lie fully in the future relative to the last bar
      if(sessStart > lastBarTime)
         continue;

      double sHigh, sLow;
      int found = GetSessionHighLow(time, high, low, rates_total, sessStart, sessEnd, sHigh, sLow);

      if(found > 0)
        {
         bool isOngoing = (sessEnd > lastBarTime); // session has not finished yet
         datetime drawEnd = sessEnd;

         if(isOngoing)
           {
            drawEnd = InpExtendCurrentSession ? TimeCurrent() : lastBarTime;
            //--- remember the forming session so OnCalculate can update it cheaply on every tick
            g_CurSessionStart = sessStart;
            g_CurSessionEnd   = sessEnd;
           }

         DrawSession(sessStart, drawEnd, sHigh, sLow);
         collected++;
        }

      //--- safety cap: never scan more than a reasonable number of calendar days back
      if(d > (InpSessionsToShow * 2) + 30)
         break;
     }
  }

//+------------------------------------------------------------------+
//| Lightweight update of only the currently forming session         |
//+------------------------------------------------------------------+
void UpdateOngoingSession(const datetime &time[], const double &high[], const double &low[], const int rates_total)
  {
   if(g_CurSessionStart == 0)
      return; // no ongoing session was registered yet (e.g. between sessions)

   double sHigh, sLow;
   int found = GetSessionHighLow(time, high, low, rates_total, g_CurSessionStart, g_CurSessionEnd, sHigh, sLow);

   if(found > 0)
     {
      datetime lastBarTime = time[rates_total - 1];
      datetime drawEnd = InpExtendCurrentSession ? TimeCurrent() : lastBarTime;
      DrawSession(g_CurSessionStart, drawEnd, sHigh, sLow);
     }
  }

//+------------------------------------------------------------------+
//| Creates or updates the chart objects for one session             |
//+------------------------------------------------------------------+
void DrawSession(const datetime sessStart, const datetime sessEnd, const double sessHigh, const double sessLow)
  {
   string tag = TimeToString(sessStart, TIME_DATE | TIME_MINUTES);

   if(InpDisplayMode == MODE_BOX)
     {
      string boxName = g_ObjPrefix + "BOX_" + tag;
      DrawOrMoveRectangle(boxName, sessStart, sessHigh, sessEnd, sessLow, InpBoxColor);
     }
   else
     {
      string highName = g_ObjPrefix + "HIGH_" + tag;
      string lowName  = g_ObjPrefix + "LOW_"  + tag;
      DrawOrMoveTrend(highName, sessStart, sessHigh, sessEnd, sessHigh, InpHighLineColor);
      DrawOrMoveTrend(lowName,  sessStart, sessLow,  sessEnd, sessLow,  InpLowLineColor);
     }

   if(InpShowLabels)
     {
      string labelName = g_ObjPrefix + "LBL_" + tag;
      string labelText = StringFormat("H: %s  L: %s",
                                       DoubleToString(sessHigh, _Digits),
                                       DoubleToString(sessLow, _Digits));
      DrawOrMoveText(labelName, sessEnd, sessHigh, labelText, InpHighLineColor);
     }
  }

//+------------------------------------------------------------------+
//| Creates a rectangle object, or moves it if it already exists     |
//+------------------------------------------------------------------+
void DrawOrMoveRectangle(const string name, const datetime t1, const double p1,
                          const datetime t2, const double p2, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, InpLineWidth);
      ObjectSetInteger(0, name, OBJPROP_FILL, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   else
     {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
     }
  }

//+------------------------------------------------------------------+
//| Creates a horizontal trend line object, or moves it if it exists |
//+------------------------------------------------------------------+
void DrawOrMoveTrend(const string name, const datetime t1, const double p1,
                      const datetime t2, const double p2, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, InpLineWidth);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   else
     {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
     }
  }

//+------------------------------------------------------------------+
//| Creates a text label object, or moves/updates it if it exists    |
//+------------------------------------------------------------------+
void DrawOrMoveText(const string name, const datetime t, const double p, const string txt, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_TEXT, txt);
     }
   else
     {
      ObjectMove(0, name, 0, t, p);
      ObjectSetString(0, name, OBJPROP_TEXT, txt);
     }
  }
//+------------------------------------------------------------------+