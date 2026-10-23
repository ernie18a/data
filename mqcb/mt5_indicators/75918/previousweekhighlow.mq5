//+------------------------------------------------------------------+
//|                                          PreviousWeekHighLow.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Draws the previous trading week's High and Low as horizontal levels "
#property description "across the current week, with support for showing several prior "
#property description "weeks at once for context."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Data Settings ==="
input int    InpWeeksToShow     = 1;             // Number of Previous Weeks to Display (1-8)

input group "=== Level Visibility ==="
input bool   InpShowHigh        = true;          // Show Previous Week High
input bool   InpShowLow         = true;          // Show Previous Week Low

input group "=== Line Style ==="
input color  InpHighColor       = clrLime;       // High Line Color
input color  InpLowColor        = clrRed;        // Low Line Color
input ENUM_LINE_STYLE InpLineStyle = STYLE_DASH;  // Line Style
input int    InpLineWidth       = 1;             // Line Width

input group "=== Labels ==="
input bool   InpShowLabels      = true;          // Show Level Labels
input bool   InpShowPriceInLabel = true;         // Include Price Value in Label
input int    InpLabelFontSize   = 8;             // Label Font Size

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string   g_ObjPrefix      = "PWHL_";   // unique prefix for all objects created by this indicator
datetime g_LastWeeklyBar  = 0;         // opening time of the last W1 bar processed

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate user input so the indicator never silently does nothing
   if(InpWeeksToShow < 1 || InpWeeksToShow > 8)
     {
      Alert("PreviousWeekHighLow: 'Weeks To Show' must be between 1 and 8.");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- give the indicator a readable name in the Data Window / object list
   IndicatorSetString(INDICATOR_SHORTNAME, "Previous Week High/Low");

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

//--- cheap check: only the W1 bar's open time is compared, so this costs
//--- nothing extra on every tick and avoids rebuilding objects unnecessarily
   datetime currentWeeklyBar = iTime(_Symbol, PERIOD_W1, 0);

   if(prev_calculated == 0 || currentWeeklyBar != g_LastWeeklyBar)
     {
      g_LastWeeklyBar = currentWeeklyBar;
      BuildLevels();
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Rebuilds the High/Low levels for each of the requested previous  |
//| weeks                                                             |
//+------------------------------------------------------------------+
void BuildLevels()
  {
   ObjectsDeleteAll(0, g_ObjPrefix);

//--- pull one extra bar so week (i-1)'s span can be bounded on both sides
   int barsNeeded = InpWeeksToShow + 2;

   MqlRates weeklyRates[];
   ArraySetAsSeries(weeklyRates, true);

   int copied = CopyRates(_Symbol, PERIOD_W1, 0, barsNeeded, weeklyRates);
   if(copied < 2)
      return; // not enough weekly history loaded yet (e.g. new chart, offline data)

//--- weeklyRates[0] is the still-forming current week, weeklyRates[1] is last week, etc.
   for(int i = 1; i < copied - 1 && i <= InpWeeksToShow; i++)
     {
      double weekHigh = weeklyRates[i].high;
      double weekLow  = weeklyRates[i].low;

      //--- the level from week 'i' is displayed across the following trading week,
      //--- i.e. the span belonging to weeklyRates[i-1]
      datetime spanStart = weeklyRates[i - 1].time;
      datetime spanEnd   = (i - 1 == 0) ? TimeCurrent() : weeklyRates[i - 2].time;

      //--- spanEnd must never end up before spanStart (guards the very first iteration)
      if(spanEnd <= spanStart)
         spanEnd = spanStart + PeriodSeconds(PERIOD_W1);

      string tag = TimeToString(weeklyRates[i].time, TIME_DATE);

      if(InpShowHigh)
         DrawLevel(g_ObjPrefix + "H_" + tag, spanStart, spanEnd, weekHigh, InpHighColor, "PWH", i);

      if(InpShowLow)
         DrawLevel(g_ObjPrefix + "L_" + tag, spanStart, spanEnd, weekLow, InpLowColor, "PWL", i);
     }
  }

//+------------------------------------------------------------------+
//| Draws one horizontal level (trend line) plus its optional label  |
//+------------------------------------------------------------------+
void DrawLevel(const string name, const datetime spanStart, const datetime spanEnd,
                const double price, const color clr, const string tagText, const int weekOffset)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, spanStart, price, spanEnd, price);
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
      ObjectMove(0, name, 0, spanStart, price);
      ObjectMove(0, name, 1, spanEnd, price);
     }

   if(!InpShowLabels)
      return;

   string labelName = name + "_LBL";

   //--- a week offset of 1 means "last week", so the base tag alone is enough;
   //--- older weeks get a "-N" suffix to stay distinguishable when stacked
   string prefixText = (weekOffset == 1) ? tagText : StringFormat("%s-%d", tagText, weekOffset - 1);

   string labelText = prefixText;
   if(InpShowPriceInLabel)
      labelText += " " + DoubleToString(price, _Digits);

   if(ObjectFind(0, labelName) < 0)
     {
      ObjectCreate(0, labelName, OBJ_TEXT, 0, spanEnd, price);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, InpLabelFontSize);
      ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
     }
   else
     {
      ObjectMove(0, labelName, 0, spanEnd, price);
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
     }
  }
//+------------------------------------------------------------------+
