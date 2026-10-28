//+--------------------------------------------------------------------------------------------------------------------+
//|                                                                                            Intraday Range Analyzer |
//|                                                                                       Vinicius Pereira De Oliveira |
//+--------------------------------------------------------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------+
//| Program properties
//+--------------------------------------------------------------------------------------------------------------------+
#property copyright   "Copyright (c) 2021-2026, Vinicius Pereira De Oliveira"
#property description "Visual indicator that calculates and displays the Average Intraday Range (AIR)"
#property description "for any custom session period. Shows historical session ranges as rectangles on"
#property description "the chart, with statistics including average, min, max and standard deviation."
#property link        "https://www.mql5.com/en/users/vinicius-fx"
#property version     "2.000"
#property strict
#property indicator_chart_window
#property indicator_plots   0
//+--------------------------------------------------------------------------------------------------------------------+
//| Define constants
//+--------------------------------------------------------------------------------------------------------------------+
#define OBJ_PREFIX        "IRA_"   // Unique prefix for chart objects
#define PANEL_NAME        "IRA_Panel"
#define MAX_LOOKBACK_DAYS 365      // Maximum number of days (sanity limit)
#define DEBUG_LOGS        false    // true = print diagnostic messages to the log

//--- Input parameter validation bounds (used by the Valid* helper functions)
#define START_HOUR_MIN     0
#define START_HOUR_MAX     23
#define END_HOUR_MIN       0
#define END_HOUR_MAX       23
#define LOOKBACK_DAYS_MIN  1
#define LOOKBACK_DAYS_MAX  MAX_LOOKBACK_DAYS
#define FONT_SIZE_MIN      6
#define FONT_SIZE_MAX      24
//+--------------------------------------------------------------------------------------------------------------------+
//| Input parameters
//+--------------------------------------------------------------------------------------------------------------------+
//
//=== Session Settings =================================================================================================
input group           "SESSION SETTINGS"
input int             InpStartHour       = 8;              // Start Hour (0-23)
input int             InpEndHour         = 17;             // End Hour (0-23)
input int             InpLookbackDays    = 10;             // Lookback Days
//
//=== Display Settings =================================================================================================
input group           "DISPLAY SETTINGS"
input bool            InpShowRectangles  = true;           // Show Session Rectangles
input bool            InpShowLabels      = true;           // Show Range Labels
input bool            InpShowPanel       = true;           // Show Info Panel
input color           InpRectangleColor  = clrDodgerBlue;  // Rectangle Color
input color           InpLabelColor      = clrWhite;       // Label Color
input color           InpPanelTextColor  = clrWhite;       // Panel Text Color
input int             InpPanelFontSize   = 9;              // Panel Font Size
//
//=== Analysis Settings ================================================================================================
input group           "ANALYSIS SETTINGS"
input ENUM_TIMEFRAMES InpAnalysisTF      = PERIOD_M5;      // Analysis Timeframe
//+--------------------------------------------------------------------------------------------------------------------+
//| Global variables
//+--------------------------------------------------------------------------------------------------------------------+
double  g_avgRange    = 0.0;
double  g_minRange    = 0.0;
double  g_maxRange    = 0.0;
double  g_stdDev      = 0.0;
int      g_sessionsCnt = 0;
datetime g_lastCalc    = 0;     // Last bar drawn (shared by OnCalculate and OnTimer)
//+--------------------------------------------------------------------------------------------------------------------+
//| Input validation helpers: clamp each input to its valid range, so the indicator
//| always runs with safe values regardless of what the user (or the validator) enters.
//+--------------------------------------------------------------------------------------------------------------------+
int ValidStartHour(int value)
  {
   return (int)MathMax(START_HOUR_MIN, MathMin(START_HOUR_MAX, value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ValidEndHour(int value)
  {
   return (int)MathMax(END_HOUR_MIN, MathMin(END_HOUR_MAX, value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ValidLookbackDays(int value)
  {
   return (int)MathMax(LOOKBACK_DAYS_MIN, MathMin(LOOKBACK_DAYS_MAX, value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ValidPanelFontSize(int value)
  {
   return (int)MathMax(FONT_SIZE_MIN, MathMin(FONT_SIZE_MAX, value));
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validates the analysis timeframe: PERIOD_CURRENT resolves to the chart TF, and any
//| non-standard value (e.g. a raw "M8" fed by the CodeBase validator) falls back to M5.
//| This keeps the indicator from trying to build exotic timeframes that stall the tester.
//+--------------------------------------------------------------------------------------------------------------------+
ENUM_TIMEFRAMES ValidAnalysisTF(ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_CURRENT)
      tf = (ENUM_TIMEFRAMES)_Period;

   switch(tf)
     {
      case PERIOD_M1:
      case PERIOD_M2:
      case PERIOD_M3:
      case PERIOD_M4:
      case PERIOD_M5:
      case PERIOD_M6:
      case PERIOD_M10:
      case PERIOD_M12:
      case PERIOD_M15:
      case PERIOD_M20:
      case PERIOD_M30:
      case PERIOD_H1:
      case PERIOD_H2:
      case PERIOD_H3:
      case PERIOD_H4:
      case PERIOD_H6:
      case PERIOD_H8:
      case PERIOD_H12:
      case PERIOD_D1:
      case PERIOD_W1:
      case PERIOD_MN1:
         return tf;                 // standard, selectable timeframe: use as-is
      default:
         return PERIOD_M5;          // non-standard value (e.g. "M8"): safe fallback
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Indicator initialization function
//+--------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
// Input parameters are validated at point of use via the Valid* helpers,
// so the indicator always initializes with safe, clamped values.

// Set the indicator short name
   string shortName = StringFormat("Intraday Range Analyzer [%02d:00-%02d:00 | %d days]",
                                   ValidStartHour(InpStartHour), ValidEndHour(InpEndHour), ValidLookbackDays(InpLookbackDays));
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);

// Clean up old objects (if any)
   CleanupObjects();

// Drive (re)drawing from a timer as well, so the first draw happens as soon as the
// asynchronous multi-timeframe data is ready, independent of incoming ticks.
// Not needed in the Strategy Tester.
   g_lastCalc = 0;
   if(!MQLInfoInteger(MQL_TESTER))
      EventSetTimer(1);

   return INIT_SUCCEEDED;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Indicator deinitialization function
//+--------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   CleanupObjects();
   ChartRedraw();
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Indicator iteration function
//+--------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int        rates_total,
                const int        prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[])
  {
   TryUpdate();
   return rates_total;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Timer handler: drives the first draw once asynchronous data is ready, even with no ticks
//+--------------------------------------------------------------------------------------------------------------------+
void OnTimer()
  {
   TryUpdate();
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Core update routine, shared by OnCalculate (tick-driven) and OnTimer (time-driven)
//+--------------------------------------------------------------------------------------------------------------------+
void TryUpdate()
  {
// Make sure the series of other timeframes (D1 and the analysis TF) are loaded. Accessing a
// timeframe other than the chart is asynchronous, so on the first pass(es) it may not be ready.
   if(!EnsureDataReady())
      return;

// Recalculate only when a new bar appears (the very first successful pass always draws)
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar == g_lastCalc && g_lastCalc != 0)
      return;
   g_lastCalc = currentBar;

// Perform the full analysis
   if(!AnalyzeIntradayRanges())
      return;

// Update the info panel
   if(InpShowPanel)
      UpdateInfoPanel();

   ChartRedraw();
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Ensures the required series (D1 and the analysis TF) are already loaded
//+--------------------------------------------------------------------------------------------------------------------+
//| Accessing a timeframe other than the current chart is asynchronous. This function
//| forces the load and confirms there are enough bars in each series before analysis.
//| Returns true only when both series are ready.
//+--------------------------------------------------------------------------------------------------------------------+
bool EnsureDataReady()
  {
// Number of D1 days the analysis needs (lookback + extra day for overnight sessions)
   int neededD1 = ValidLookbackDays(InpLookbackDays) + 2;

// --- D1 series ---
   datetime d1Probe[];
   int d1Copied = CopyTime(_Symbol, PERIOD_D1, 0, neededD1, d1Probe);
   if(d1Copied < neededD1)
     {
      // Data still loading: trigger the request and retry on the next tick (no error log)
      return false;
     }

// --- Analysis timeframe series ---
// We need enough history to cover the lookback period on the analysis TF.
   int barsAnalysisTF = Bars(_Symbol, ValidAnalysisTF(InpAnalysisTF));
   if(barsAnalysisTF <= 0)
     {
      // Trigger loading of the analysis TF
      datetime tfProbe[];
      CopyTime(_Symbol, ValidAnalysisTF(InpAnalysisTF), 0, 1, tfProbe);
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Performs the full intraday range analysis
//+--------------------------------------------------------------------------------------------------------------------+
bool AnalyzeIntradayRanges()
  {
// Reset statistics
   g_avgRange    = 0.0;
   g_minRange    = DBL_MAX;
   g_maxRange    = 0.0;
   g_sessionsCnt = 0;

// Array to store ranges (for standard deviation calculation)
   double ranges[];
   ArrayResize(ranges, ValidLookbackDays(InpLookbackDays));
   ArrayInitialize(ranges, 0.0);

// Clean up old rectangles and labels before recreating
   CleanupObjects();

// Detect whether the session crosses midnight (overnight)
   bool isOvernight = (ValidStartHour(InpStartHour) > ValidEndHour(InpEndHour));

// Determine whether the current day should be included
   int startIdx = 1;
   int endIdx   = ValidLookbackDays(InpLookbackDays);

   MqlDateTime currentTime;
   if(!TimeToStruct(TimeCurrent(), currentTime))
     {
      Print("<", __FUNCTION__, "> Error converting current time to struct");
      return false;
     }

// If the current session has fully passed, include day 0
   bool currentSessionPassed;
   if(isOvernight)
      currentSessionPassed = (currentTime.hour >= ValidEndHour(InpEndHour) && currentTime.hour < ValidStartHour(InpStartHour));
   else
      currentSessionPassed = (currentTime.hour >= ValidEndHour(InpEndHour));

   if(currentSessionPassed)
     {
      startIdx = 0;
      endIdx   = ValidLookbackDays(InpLookbackDays) - 1;
     }

// Iterate through the lookback days
   int validSessions = 0;
   for(int dayIdx = startIdx; dayIdx <= endIdx; dayIdx++)
     {
      datetime sessionStart, sessionEnd;

      if(!GetSessionTimes(dayIdx, isOvernight, sessionStart, sessionEnd))
         continue;

      // Compute the session high/low using the analysis timeframe
      double sessionHigh = 0.0, sessionLow = 0.0;
      if(!GetSessionHighLow(sessionStart, sessionEnd, sessionHigh, sessionLow))
         continue;

      double range = sessionHigh - sessionLow;
      if(range <= 0.0)
         continue;

      // Update statistics
      ranges[validSessions] = range;
      g_avgRange += range;

      if(range < g_minRange)
         g_minRange = range;
      if(range > g_maxRange)
         g_maxRange = range;

      // Draw the session rectangle (if enabled)
      if(InpShowRectangles)
         DrawSessionRectangle(validSessions, sessionStart, sessionEnd, sessionHigh, sessionLow);

      // Draw the range value label (if enabled)
      if(InpShowLabels)
         DrawRangeLabel(validSessions, sessionStart, sessionEnd, sessionHigh, sessionLow, range);

      validSessions++;
     }

// Final statistics calculation
   if(validSessions == 0)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> No valid sessions found for analysis");
      g_minRange = 0.0;
      return false;
     }

   g_sessionsCnt = validSessions;
   g_avgRange   /= validSessions;

// Standard deviation
   double variance = 0.0;
   for(int i = 0; i < validSessions; i++)
      variance += MathPow(ranges[i] - g_avgRange, 2);
   variance /= validSessions;
   g_stdDev = MathSqrt(variance);

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Computes the start and end timestamps of a session for a given dayIdx
//+--------------------------------------------------------------------------------------------------------------------+
bool GetSessionTimes(int dayIdx, bool isOvernight, datetime &sessionStart, datetime &sessionEnd)
  {
   datetime dayTime = iTime(_Symbol, PERIOD_D1, dayIdx);
   if(dayTime == 0)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> Could not get day time for index ", dayIdx);
      return false;
     }

// Define the start and end times
   if(isOvernight)
     {
      // Overnight session: starts on the previous day, ends on the current day
      datetime prevDayTime = iTime(_Symbol, PERIOD_D1, dayIdx + 1);
      if(prevDayTime == 0)
        {
         if(DEBUG_LOGS)
            Print("<", __FUNCTION__, "> Could not get previous day time for overnight session");
         return false;
        }
      sessionStart = prevDayTime + ValidStartHour(InpStartHour) * PeriodSeconds(PERIOD_H1);
      sessionEnd   = dayTime     + ValidEndHour(InpEndHour)   * PeriodSeconds(PERIOD_H1);
     }
   else
     {
      // Normal session: same day
      sessionStart = dayTime + ValidStartHour(InpStartHour) * PeriodSeconds(PERIOD_H1);
      sessionEnd   = dayTime + ValidEndHour(InpEndHour)   * PeriodSeconds(PERIOD_H1);
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Gets the High/Low of a session using the analysis timeframe
//+--------------------------------------------------------------------------------------------------------------------+
bool GetSessionHighLow(datetime sessionStart, datetime sessionEnd, double &sessionHigh, double &sessionLow)
  {
   int startShift = iBarShift(_Symbol, ValidAnalysisTF(InpAnalysisTF), sessionStart, false);
   int endShift   = iBarShift(_Symbol, ValidAnalysisTF(InpAnalysisTF), sessionEnd,   false);

   if(startShift < 0 || endShift < 0)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> Time not found in available history for session ",
               TimeToString(sessionStart), " - ", TimeToString(sessionEnd));
      return false;
     }

   if(startShift <= endShift)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> Invalid bar range for session");
      return false;
     }

   int barCount = startShift - endShift + 1;

   int highestIdx = iHighest(_Symbol, ValidAnalysisTF(InpAnalysisTF), MODE_HIGH, barCount, endShift);
   int lowestIdx  = iLowest(_Symbol,  ValidAnalysisTF(InpAnalysisTF), MODE_LOW,  barCount, endShift);

   if(highestIdx < 0 || lowestIdx < 0)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> Could not find highest/lowest bars");
      return false;
     }

   sessionHigh = iHigh(_Symbol, ValidAnalysisTF(InpAnalysisTF), highestIdx);
   sessionLow  = iLow(_Symbol,  ValidAnalysisTF(InpAnalysisTF), lowestIdx);

   if(sessionHigh <= 0.0 || sessionLow <= 0.0)
     {
      if(DEBUG_LOGS)
         Print("<", __FUNCTION__, "> Invalid high/low values");
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Draws the session rectangle on the chart
//+--------------------------------------------------------------------------------------------------------------------+
void DrawSessionRectangle(int idx, datetime t1, datetime t2, double price1, double price2)
  {
   string name = OBJ_PREFIX + "Rect_" + IntegerToString(idx);

   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, price1, t2, price2))
     {
      Print("<", __FUNCTION__, "> Failed to create rectangle: ", GetLastError());
      return;
     }

   ObjectSetInteger(0, name, OBJPROP_COLOR, InpRectangleColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Draws the label with the range value
//+--------------------------------------------------------------------------------------------------------------------+
void DrawRangeLabel(int idx, datetime t1, datetime t2, double price1, double price2, double range)
  {
   string name = OBJ_PREFIX + "Label_" + IntegerToString(idx);

// Center position of the rectangle
   datetime midTime  = (datetime)((long)t1 + ((long)t2 - (long)t1) / 2);
   double   midPrice = (price1 + price2) / 2.0;

   double rangePoints = range / _Point;
   string text = StringFormat("%d pts", (int)MathRound(rangePoints));

   if(!ObjectCreate(0, name, OBJ_TEXT, 0, midTime, midPrice))
     {
      Print("<", __FUNCTION__, "> Failed to create label: ", GetLastError());
      return;
     }

   ObjectSetString(0,  name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpLabelColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0,  name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Updates the info panel in the chart corner
//+--------------------------------------------------------------------------------------------------------------------+
//| OBJ_LABEL renders only ONE line of text (it ignores '\n'). Therefore each panel
//| line is drawn as a separate OBJ_LABEL, stacked vertically.
//+--------------------------------------------------------------------------------------------------------------------+
void UpdateInfoPanel()
  {
// Build the panel lines
   string lines[];
   ArrayResize(lines, 9);
   lines[0] = "INTRADAY RANGE ANALYZER";
   lines[1] = "-----------------------";
   lines[2] = StringFormat("Session: %02d:00 - %02d:00", ValidStartHour(InpStartHour), ValidEndHour(InpEndHour));
   lines[3] = StringFormat("Sessions analyzed: %d", g_sessionsCnt);
   lines[4] = "-----------------------";
   lines[5] = StringFormat("Average:  %d pts", (int)MathRound(g_avgRange / _Point));
   lines[6] = StringFormat("Minimum:  %d pts", (int)MathRound(g_minRange / _Point));
   lines[7] = StringFormat("Maximum:  %d pts", (int)MathRound(g_maxRange / _Point));
   lines[8] = StringFormat("Std Dev:  %d pts", (int)MathRound(g_stdDev   / _Point));

   int lineCount = ArraySize(lines);

// Vertical spacing between lines (proportional to the font size)
   int lineSpacing = ValidPanelFontSize(InpPanelFontSize) + 6;
   int xStart      = 10;
   int yStart      = 25;

   for(int i = 0; i < lineCount; i++)
     {
      string lineName = StringFormat("%sPanel_%02d", OBJ_PREFIX, i);

      if(ObjectFind(0, lineName) < 0)
        {
         if(!ObjectCreate(0, lineName, OBJ_LABEL, 0, 0, 0))
           {
            Print("<", __FUNCTION__, "> Failed to create panel line ", i, ": ", GetLastError());
            continue;
           }
         ObjectSetInteger(0, lineName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, lineName, OBJPROP_XDISTANCE, xStart);
         ObjectSetInteger(0, lineName, OBJPROP_YDISTANCE, yStart + i * lineSpacing);
         ObjectSetInteger(0, lineName, OBJPROP_FONTSIZE, ValidPanelFontSize(InpPanelFontSize));
         ObjectSetString(0,  lineName, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
        }

      ObjectSetString(0,  lineName, OBJPROP_TEXT, lines[i]);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpPanelTextColor);
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Removes all objects created by the indicator
//+--------------------------------------------------------------------------------------------------------------------+
void CleanupObjects()
  {
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, OBJ_PREFIX) == 0)
         ObjectDelete(0, name);
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Indicator End
//+--------------------------------------------------------------------------------------------------------------------+
