//+------------------------------------------------------------------+
//|                                   AsianFibBreakout_Indicator.mq5 |
//|                                 Copyright 2026, Trading Strategy |
//+------------------------------------------------------------------+
#property copyright "Trading Strategy"
#property link      "https://www.mql5.com/en/users/searchmixed/seller"
#property version   "1.10"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Inputs
input group "--- Asian Range Settings (GMT) ---"
input int      InpAsianStartHour = 1;         // Asian Start Hour (GMT)
input int      InpAsianEndHour   = 5;         // Asian End Hour (GMT)

input group "--- Session Trade Settings ---"
input int      InpTradeStartHour = 7;         // London Open Hour (GMT)
input int      InpTradeEndHour   = 18;        // Session End Hour (GMT)
input int      InpDaysBack       = 10;        // Number of past days to draw

input group "--- Visual Styling ---"
input color    InpAsianBoxColor  = clrLightYellow; // Asian Range Box Color
input color    InpAsianLineColor = clrOrange;      // Asian High/Low Line Color
input color    InpEntryColor     = clrTeal;        // 60% Entry Color
input color    InpSLColor        = clrRed;         // 80% Stop Loss Color
input color    InpTPColor        = clrLime;        // 5R Target Color

#define PREFIX "AsianFib_"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAllPrefix(PREFIX);
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
// Refresh visual objects
   static datetime lastCalc = 0;
   if(TimeCurrent() - lastCalc < 2 && prev_calculated > 0)
      return(rates_total);
   lastCalc = TimeCurrent();

   ObjectsDeleteAllPrefix(PREFIX);

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, 3000, rates);
   if(copied <= 0)
      return(rates_total);

   datetime currentDay = 0;
   int processedDays = 0;

   for(int i = 0; i < copied && processedDays < InpDaysBack; i++)
     {
      MqlDateTime dt;
      TimeToStruct(rates[i].time, dt);

      datetime dayTime = StructToTime(dt) - (dt.hour * 3600 + dt.min * 60 + dt.sec);

      if(dayTime != currentDay)
        {
         currentDay = dayTime;
         ProcessDay(dayTime, rates, copied);
         processedDays++;
        }
     }

   ChartRedraw(0);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Process single day setup (Chrono Sequential - Non Repainting)   |
//+------------------------------------------------------------------+
void ProcessDay(datetime dayStart, const MqlRates &rates[], int totalRates)
  {
   double asianHigh = -1.0, asianLow = 999999.0;
   datetime asianStartTime = 0, asianEndTime = 0;
   bool asianFound = false;

// 1. Identify Asian Session Range (1:00 to 5:00 GMT)
   for(int i = totalRates - 1; i >= 0; i--)
     {
      MqlDateTime dt;
      TimeToStruct(rates[i].time, dt);
      datetime barDay = rates[i].time - (dt.hour * 3600 + dt.min * 60 + dt.sec);

      if(barDay == dayStart && dt.hour >= InpAsianStartHour && dt.hour < InpAsianEndHour)
        {
         if(rates[i].high > asianHigh)
            asianHigh = rates[i].high;
         if(rates[i].low < asianLow)
            asianLow  = rates[i].low;
         if(asianStartTime == 0)
            asianStartTime = rates[i].time;
         asianEndTime = rates[i].time;
         asianFound = true;
        }
     }

   if(!asianFound || asianHigh <= 0 || asianLow >= 999999.0)
      return;

   string dayStr = TimeToString(dayStart, TIME_DATE);

// Draw Asian Box
   string boxName = PREFIX + "Box_" + dayStr;
   ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, asianStartTime, asianHigh, asianEndTime + 3600, asianLow);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpAsianBoxColor);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);

// Draw Asian High & Low lines
   DrawTrendLine(PREFIX + "AHigh_" + dayStr, asianStartTime, asianHigh, asianEndTime + 86400, asianHigh, InpAsianLineColor, STYLE_SOLID, 1);
   DrawText(PREFIX + "TxtAHigh_" + dayStr, asianEndTime + 3600, asianHigh, "Asian High", InpAsianLineColor);

   DrawTrendLine(PREFIX + "ALow_" + dayStr, asianStartTime, asianLow, asianEndTime + 86400, asianLow, InpAsianLineColor, STYLE_SOLID, 1);
   DrawText(PREFIX + "TxtALow_" + dayStr, asianEndTime + 3600, asianLow, "Asian Low", InpAsianLineColor);

// 2. Sequential Chronological Search for Breakout and Entry Lock-in
   bool breakoutOccurred = false;
   bool entryTriggered   = false;
   datetime initialBreakoutTime = 0;
   double runningHigh = 0.0;
   double lockedHigh  = 0.0;

// Iterate forward in time through the day
   for(int i = totalRates - 1; i >= 0; i--)
     {
      MqlDateTime dt;
      TimeToStruct(rates[i].time, dt);
      datetime barDay = rates[i].time - (dt.hour * 3600 + dt.min * 60 + dt.sec);

      if(barDay == dayStart && dt.hour >= InpTradeStartHour && dt.hour < InpTradeEndHour)
        {
         // Detect Initial Breakout (Fixes moving arrow)
         if(!breakoutOccurred && rates[i].high > asianHigh)
           {
            breakoutOccurred = true;
            initialBreakoutTime = rates[i].time; // Fixed Arrow Time
            runningHigh = rates[i].high;
           }

         // If breakout happened, track impulse peak until Entry is touched
         if(breakoutOccurred && !entryTriggered)
           {
            if(rates[i].high > runningHigh)
              {
               runningHigh = rates[i].high;
              }

            // Calculate active 60% Fib Entry level
            double candRange = runningHigh - asianLow;
            double candEntry = runningHigh - (0.60 * candRange);

            // Did price retrace to the 60% Entry level?
            if(rates[i].low <= candEntry)
              {
               entryTriggered = true;
               lockedHigh = runningHigh; // FREEZE FIBONACCI HIGH PERMANENTLY!
              }
           }
        }
     }

// 3. Draw Fixed Arrow and Locked Fibonacci Levels
   if(breakoutOccurred)
     {
      // Final High to use: Locked high if triggered, otherwise max running high
      double finalHigh = entryTriggered ? lockedHigh : runningHigh;

      double range = finalHigh - asianLow;
      if(range <= 0)
         return;

      double entryPrice = finalHigh - (0.60 * range); // 60% Fib Entry
      double slPrice    = finalHigh - (0.80 * range); // 80% Fib SL
      double risk       = entryPrice - slPrice;
      double tpPrice    = entryPrice + (risk * 5.0);   // 5R Target

      datetime lineEnd = initialBreakoutTime + (12 * 3600);

      // FIXED BREAKOUT ARROW (Placed at initial breakout bar)
      string arrowName = PREFIX + "Arrow_" + dayStr;
      ObjectCreate(0, arrowName, OBJ_ARROW_UP, 0, initialBreakoutTime, asianHigh);
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrLime);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);

      // FIXED FIBONACCI LEVELS
      // Entry Line (60%)
      DrawTrendLine(PREFIX + "Entry_" + dayStr, initialBreakoutTime, entryPrice, lineEnd, entryPrice, InpEntryColor, STYLE_SOLID, 2);
      DrawText(PREFIX + "TxtEntry_" + dayStr, lineEnd, entryPrice, "ENTRY (60% Fib)", InpEntryColor);

      // Stop Loss Line (80%)
      DrawTrendLine(PREFIX + "SL_" + dayStr, initialBreakoutTime, slPrice, lineEnd, slPrice, InpSLColor, STYLE_SOLID, 2);
      DrawText(PREFIX + "TxtSL_" + dayStr, lineEnd, slPrice, "STOP LOSS (80% Fib)", InpSLColor);

      // Take Profit Line (5R)
      DrawTrendLine(PREFIX + "TP_" + dayStr, initialBreakoutTime, tpPrice, lineEnd, tpPrice, InpTPColor, STYLE_DASH, 2);
      DrawText(PREFIX + "TxtTP_" + dayStr, lineEnd, tpPrice, "TARGET (5R)", InpTPColor);
     }
  }

//+------------------------------------------------------------------+
//| Helper: Draw Trend Line                                          |
//+------------------------------------------------------------------+
void DrawTrendLine(string name, datetime t1, double p1, datetime t2, double p2, color col, ENUM_LINE_STYLE style, int width)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
  }

//+------------------------------------------------------------------+
//| Helper: Draw Text Label                                          |
//+------------------------------------------------------------------+
void DrawText(string name, datetime t, double p, string text, color col)
  {
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, "  " + text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
  }

//+------------------------------------------------------------------+
//| Helper: Delete Objects by Prefix                                 |
//+------------------------------------------------------------------+
void ObjectsDeleteAllPrefix(string prefix)
  {
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i = obj_total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, prefix) == 0)
        {
         ObjectDelete(0, name);
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
