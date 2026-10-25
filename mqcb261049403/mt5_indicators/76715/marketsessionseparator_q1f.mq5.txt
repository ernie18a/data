//+------------------------------------------------------------------+
//|                                       MarketSessionSeparator.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Marks the start/end of up to three trading sessions (e.g. Asian, London, "
#property description "New York) with vertical separators and/or full-height shaded boxes, "
#property description "repeated daily across a rolling recent window."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- how the sessions are visualized
enum ENUM_SEP_DRAW_MODE
  {
   SEP_LINES = 0,  // Vertical Lines Only
   SEP_BOXES = 1,  // Shaded Boxes Only
   SEP_BOTH  = 2   // Vertical Lines + Shaded Boxes
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Session 1 (e.g. Asian) ==="
input bool   InpEnableSession1     = true;         // Enable Session 1
input int    InpSession1StartHour  = 0;             // Start Hour (server time)
input int    InpSession1StartMin   = 0;             // Start Minute
input int    InpSession1EndHour    = 8;             // End Hour (server time)
input int    InpSession1EndMin     = 0;             // End Minute
input color  InpSession1Color      = clrSteelBlue;  // Color
input string InpSession1Label      = "Asian";       // Label Text

input group "=== Session 2 (e.g. London) ==="
input bool   InpEnableSession2     = true;          // Enable Session 2
input int    InpSession2StartHour  = 8;              // Start Hour (server time)
input int    InpSession2StartMin   = 0;              // Start Minute
input int    InpSession2EndHour    = 16;             // End Hour (server time)
input int    InpSession2EndMin     = 0;              // End Minute
input color  InpSession2Color      = clrGoldenrod;   // Color
input string InpSession2Label      = "London";       // Label Text

input group "=== Session 3 (e.g. New York) ==="
input bool   InpEnableSession3     = true;          // Enable Session 3
input int    InpSession3StartHour  = 13;             // Start Hour (server time)
input int    InpSession3StartMin   = 0;              // Start Minute
input int    InpSession3EndHour    = 21;             // End Hour (server time)
input int    InpSession3EndMin     = 0;              // End Minute
input color  InpSession3Color      = clrMediumSeaGreen; // Color
input string InpSession3Label      = "New York";     // Label Text

input group "=== Display Settings ==="
input ENUM_SEP_DRAW_MODE InpDrawMode = SEP_BOTH; // Draw Mode
input bool   InpShowLabels    = true;   // Show Session Name Labels
input int    InpLabelFontSize = 8;      // Label Font Size
input int    InpDaysToDraw    = 10;     // Rolling Window (calendar days back to draw)
input bool   InpSkipWeekends  = true;   // Skip Saturday/Sunday
input ENUM_LINE_STYLE InpLineStyle = STYLE_DOT; // Vertical Line Style

//+------------------------------------------------------------------+
//| Global variables — a single registry of every object this        |
//| indicator has created, tagged with the calendar day it belongs   |
//| to, so the rolling window can be pruned cheaply as days pass      |
//+------------------------------------------------------------------+
string   g_Prefix = "MSS_";

string   g_ObjName[];
datetime g_ObjDay[];
int      g_ObjCount = 0;

datetime g_LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDaysToDraw < 1)
     {
      Alert("MarketSessionSeparator: 'Rolling Window' must be at least 1 day.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Market Session Separator");

   g_ObjCount = 0;
   ArrayResize(g_ObjName, 0);
   ArrayResize(g_ObjDay, 0);

   g_LastBarTime = 0; // forces a full build on the very first OnCalculate call

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove every chart object this indicator has created, identified by its unique prefix
   ObjectsDeleteAll(0, g_Prefix);
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
   if(rates_total < 1)
      return(0);

//--- session boundaries only depend on the calendar day, not on individual
//--- bars, so this only needs to run once per new bar — never per tick, and
//--- never by rescanning the chart's history. Objects for days already
//--- inside the rolling window are skipped (ObjectFind check), so a normal
//--- refresh only ever creates objects for the single newest day.
   datetime currentBarTime = time[rates_total - 1];
   bool isNewBar = (prev_calculated == 0 || currentBarTime != g_LastBarTime);
   g_LastBarTime = currentBarTime;

   if(isNewBar)
     {
      BuildSeparators(currentBarTime);
      RefreshVisualExtents();
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Chart event handler — keeps shaded boxes and labels matching the |
//| visible price range immediately after the user scrolls or zooms, |
//| instead of waiting for the next new bar                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      RefreshVisualExtents();
  }

//+------------------------------------------------------------------+
//| Creates any missing session objects for the rolling window of    |
//| the last InpDaysToDraw calendar days, and prunes objects that     |
//| have fallen outside that window                                  |
//+------------------------------------------------------------------+
void BuildSeparators(const datetime lastBarTime)
  {
   datetime todayBase = lastBarTime - (lastBarTime % 86400);

   for(int d = 0; d < InpDaysToDraw; d++)
     {
      datetime dayBase = todayBase - (datetime)d * 86400;

      if(InpSkipWeekends)
        {
         MqlDateTime dt;
         TimeToStruct(dayBase, dt);
         int dow = dt.day_of_week; // 0 = Sunday ... 6 = Saturday
         if(dow == 0 || dow == 6)
            continue;
        }

      CreateSessionForDay(dayBase, 1, InpEnableSession1, InpSession1StartHour, InpSession1StartMin,
                           InpSession1EndHour, InpSession1EndMin, InpSession1Color, InpSession1Label);
      CreateSessionForDay(dayBase, 2, InpEnableSession2, InpSession2StartHour, InpSession2StartMin,
                           InpSession2EndHour, InpSession2EndMin, InpSession2Color, InpSession2Label);
      CreateSessionForDay(dayBase, 3, InpEnableSession3, InpSession3StartHour, InpSession3StartMin,
                           InpSession3EndHour, InpSession3EndMin, InpSession3Color, InpSession3Label);
     }

//--- prune every tracked object belonging to a day older than the window
   datetime cutoff = todayBase - (datetime)InpDaysToDraw * 86400;
   int i = 0;
   while(i < g_ObjCount)
     {
      if(g_ObjDay[i] < cutoff)
         RemoveObjectAt(i); // shifts the array down, so do not advance i here
      else
         i++;
     }
  }

//+------------------------------------------------------------------+
//| Creates the line(s)/box/label for one session on one calendar day |
//| — skips anything that already exists (ObjectFind check), so a     |
//| normal refresh only ever creates objects for the newest day       |
//+------------------------------------------------------------------+
void CreateSessionForDay(const datetime dayBase, const int sessionIndex, const bool enabled,
                          const int startHour, const int startMin, const int endHour, const int endMin,
                          const color clr, const string labelText)
  {
   if(!enabled)
      return;

   int startSec = startHour * 3600 + startMin * 60;
   int endSec   = endHour * 3600 + endMin * 60;

   datetime sessStart = dayBase + startSec;
   datetime sessEnd   = dayBase + endSec;
   if(endSec <= startSec)
      sessEnd += 86400; // handles an overnight session, e.g. 21:00 -> 05:00

   string tag = TimeToString(dayBase, TIME_DATE) + "_S" + IntegerToString(sessionIndex);

   if(InpDrawMode == SEP_LINES || InpDrawMode == SEP_BOTH)
     {
      CreateVLine(g_Prefix + "Start_" + tag, sessStart, clr, dayBase);
      CreateVLine(g_Prefix + "End_" + tag, sessEnd, clr, dayBase);
     }

   if(InpDrawMode == SEP_BOXES || InpDrawMode == SEP_BOTH)
      CreateBox(g_Prefix + "Box_" + tag, sessStart, sessEnd, clr, dayBase);

   if(InpShowLabels)
      CreateLabel(g_Prefix + "Lbl_" + tag, sessStart, clr, labelText, dayBase);
  }

//+------------------------------------------------------------------+
//| Creates a full-height vertical separator line (skips if it        |
//| already exists — a historical day's line never needs to move)    |
//+------------------------------------------------------------------+
void CreateVLine(const string name, const datetime t, const color clr, const datetime dayBase)
  {
   if(ObjectFind(0, name) >= 0)
      return;

   ObjectCreate(0, name, OBJ_VLINE, 0, t, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

   AddTrackedObject(name, dayBase);
  }

//+------------------------------------------------------------------+
//| Creates a shaded background box spanning the session's time      |
//| range and the chart's current visible price range                |
//+------------------------------------------------------------------+
void CreateBox(const string name, const datetime x1, const datetime x2, const color clr, const datetime dayBase)
  {
   if(ObjectFind(0, name) >= 0)
      return;

   double priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   double priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
   if(priceMax <= priceMin)
     {
      priceMin = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.98;
      priceMax = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 1.02;
     }

   ObjectCreate(0, name, OBJ_RECTANGLE, 0, x1, priceMin, x2, priceMax);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);

   AddTrackedObject(name, dayBase);
  }

//+------------------------------------------------------------------+
//| Creates a session-name label positioned near the top of the      |
//| chart's current visible price range                              |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const datetime t, const color clr, const string text, const datetime dayBase)
  {
   if(ObjectFind(0, name) >= 0)
      return;

   double priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   double priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
   if(priceMax <= priceMin)
     {
      priceMin = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.98;
      priceMax = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 1.02;
     }
   double margin = (priceMax - priceMin) * 0.03;

   ObjectCreate(0, name, OBJ_TEXT, 0, t, priceMax - margin);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpLabelFontSize);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_TEXT, text);

   AddTrackedObject(name, dayBase);
  }

//+------------------------------------------------------------------+
//| Re-syncs every tracked box/label's price coordinates to the       |
//| chart's current visible price range (cheap — object count is     |
//| bounded by InpDaysToDraw)                                        |
//+------------------------------------------------------------------+
void RefreshVisualExtents()
  {
   double priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   double priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
   if(priceMax <= priceMin)
      return; // chart not fully initialized yet

   double margin = (priceMax - priceMin) * 0.03;

   for(int i = 0; i < g_ObjCount; i++)
     {
      string name = g_ObjName[i];

      if(StringFind(name, g_Prefix + "Box_") == 0)
        {
         datetime t1 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME, 0);
         datetime t2 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME, 1);
         ObjectMove(0, name, 0, t1, priceMin);
         ObjectMove(0, name, 1, t2, priceMax);
        }
      else
         if(StringFind(name, g_Prefix + "Lbl_") == 0)
           {
            datetime t1 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME, 0);
            ObjectMove(0, name, 0, t1, priceMax - margin);
           }
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Appends an object to the tracking registry                       |
//+------------------------------------------------------------------+
void AddTrackedObject(const string name, const datetime dayBase)
  {
   int n = g_ObjCount;
   ArrayResize(g_ObjName, n + 1);
   ArrayResize(g_ObjDay, n + 1);
   g_ObjName[n] = name;
   g_ObjDay[n]  = dayBase;
   g_ObjCount++;
  }

//+------------------------------------------------------------------+
//| Removes the tracked object at index idx: deletes its chart object |
//| and shifts every later entry down by one                         |
//+------------------------------------------------------------------+
void RemoveObjectAt(const int idx)
  {
   if(idx < 0 || idx >= g_ObjCount)
      return;

   ObjectDelete(0, g_ObjName[idx]);

   for(int k = idx; k < g_ObjCount - 1; k++)
     {
      g_ObjName[k] = g_ObjName[k + 1];
      g_ObjDay[k]  = g_ObjDay[k + 1];
     }

   g_ObjCount--;
   ArrayResize(g_ObjName, g_ObjCount);
   ArrayResize(g_ObjDay, g_ObjCount);
  }
//+------------------------------------------------------------------+
