//+------------------------------------------------------------------+
//|                                       LiquiditySweepDetector.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Marks fractal swing highs/lows as liquidity levels, then flags the exact "
#property description "bar where price wicks beyond one and closes back inside — a liquidity "
#property description "sweep / stop hunt — with an arrow and an optional label."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Swing (Liquidity Level) Detection ==="
input int InpSwingLookback     = 5;   // Swing Lookback (bars on each side to confirm a pivot)
input int InpMaxLevelsToTrack  = 20;  // Maximum Levels Kept on Chart (oldest removed first)

input group "=== Sweep Detection ==="
input int  InpMinWickPoints           = 30;   // Minimum Wick Beyond Level to Count as a Sweep (points)
input bool InpRequireCloseBackInside  = true; // Require the Candle to Close Back Inside the Level
input bool InpOneSweepPerLevel        = true; // Stop Checking a Level After Its First Sweep

input group "=== Level Display ==="
input bool InpShowLevels              = true; // Draw the Liquidity Level Lines
input bool InpExtendLevelsUntilSwept  = true; // Extend Unswept Levels Live to the Current Bar
input int  InpLevelExtendBars         = 50;   // Fixed Extension (bars) — used only if not extending until swept

input group "=== Colors & Markers ==="
input color InpLevelColor        = clrSilver;   // Liquidity Level Line Color (before being swept)
input color InpSweptLevelColor   = clrDimGray;  // Level Line Color After Being Swept
input color InpBullishSweepColor = clrLime;     // Arrow/Label Color — Bullish Sweep (swept a low)
input color InpBearishSweepColor = clrRed;      // Arrow/Label Color — Bearish Sweep (swept a high)
input bool  InpShowLabels        = true;        // Show a "SWEEP" Price Label at Each Signal
input int   InpArrowWidth        = 2;           // Arrow Marker Width

//+------------------------------------------------------------------+
//| Global variables — parallel arrays tracking every liquidity      |
//| level currently kept on the chart                                |
//+------------------------------------------------------------------+
string   g_Prefix = "LSD_";

int      g_LevelFormIndex[];  // bar index at which the pivot was confirmed
double   g_LevelPrice[];      // the level's price (the pivot high or low)
bool     g_LevelIsHigh[];     // true = swing high (resistance/liquidity above), false = swing low
bool     g_LevelSwept[];      // true once this level has produced a sweep
string   g_LevelLineName[];   // chart object name of the level's line (may be "" if InpShowLevels is false)
int      g_LevelCount = 0;

int g_LastConfirmedPivotIndex = -1; // last bar index already checked for a new swing pivot
int g_LastProcessedSweepIndex = -1; // last closed bar index already checked against active levels

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwingLookback < 1)
     {
      Alert("LiquiditySweepDetector: 'Swing Lookback' must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMaxLevelsToTrack < 1)
     {
      Alert("LiquiditySweepDetector: 'Maximum Levels Kept on Chart' must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Liquidity Sweep Detector");

   ResetState();

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
//| Clears all tracked levels and chart objects — used on first run  |
//| and whenever the terminal forces a full recalculation             |
//+------------------------------------------------------------------+
void ResetState()
  {
   ObjectsDeleteAll(0, g_Prefix);

   g_LevelCount = 0;
   ArrayResize(g_LevelFormIndex, 0);
   ArrayResize(g_LevelPrice, 0);
   ArrayResize(g_LevelIsHigh, 0);
   ArrayResize(g_LevelSwept, 0);
   ArrayResize(g_LevelLineName, 0);

   g_LastConfirmedPivotIndex = InpSwingLookback - 1;
   g_LastProcessedSweepIndex = -1;
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
//--- a fractal pivot needs InpSwingLookback bars on both sides, plus the
//--- currently forming bar, as a practical minimum
   if(rates_total < 2 * InpSwingLookback + 3)
      return(0);

   if(prev_calculated == 0)
      ResetState();

//--- 1) confirm any new swing pivots. A bar at index i can only be confirmed
//--- once InpSwingLookback bars exist after it, so the confirmable frontier
//--- always trails the current bar by that many bars — only the newly
//--- confirmable indices since the last call are checked, never the full history
   int confirmIndex = rates_total - 1 - InpSwingLookback;

   for(int i = g_LastConfirmedPivotIndex + 1; i <= confirmIndex; i++)
     {
      if(i - InpSwingLookback < 0)
         continue;

      if(IsSwingHigh(i, high))
         AddLevel(i, time, high[i], true);

      if(IsSwingLow(i, low))
         AddLevel(i, time, low[i], false);
     }

   if(confirmIndex > g_LastConfirmedPivotIndex)
      g_LastConfirmedPivotIndex = confirmIndex;

//--- 2) sweep detection, evaluated only on fully closed bars for stability
//--- (a still-forming candle's high/low/close can still change)
   int lastClosedIndex = rates_total - 2;
   int sweepStart = g_LastProcessedSweepIndex + 1;

   for(int j = sweepStart; j <= lastClosedIndex; j++)
     {
      for(int L = 0; L < g_LevelCount; L++)
        {
         if(g_LevelSwept[L])
            continue;
         if(g_LevelFormIndex[L] >= j)
            continue; // the level must already exist before the bar being checked

         CheckSweep(L, j, time, high, low, close);
        }
     }

   if(lastClosedIndex > g_LastProcessedSweepIndex)
      g_LastProcessedSweepIndex = lastClosedIndex;

//--- 3) live-extend every still-active level's line to the current
//--- (possibly still-forming) bar — cheap, runs every tick
   if(InpShowLevels && InpExtendLevelsUntilSwept)
     {
      datetime edge = time[rates_total - 1];
      for(int L = 0; L < g_LevelCount; L++)
         if(!g_LevelSwept[L] && g_LevelLineName[L] != "")
            ObjectMove(0, g_LevelLineName[L], 1, edge, g_LevelPrice[L]);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| True if bar i is a strict local maximum of High over the window  |
//| [i - InpSwingLookback, i + InpSwingLookback]                     |
//+------------------------------------------------------------------+
bool IsSwingHigh(const int i, const double &high[])
  {
   for(int k = i - InpSwingLookback; k <= i + InpSwingLookback; k++)
     {
      if(k == i)
         continue;
      if(high[k] >= high[i])
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| True if bar i is a strict local minimum of Low over the window   |
//| [i - InpSwingLookback, i + InpSwingLookback]                     |
//+------------------------------------------------------------------+
bool IsSwingLow(const int i, const double &low[])
  {
   for(int k = i - InpSwingLookback; k <= i + InpSwingLookback; k++)
     {
      if(k == i)
         continue;
      if(low[k] <= low[i])
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Registers a newly confirmed swing level: draws its line (if       |
//| enabled) and appends it to the tracking arrays, enforcing the cap |
//+------------------------------------------------------------------+
void AddLevel(const int i, const datetime &time[], const double price, const bool isHigh)
  {
   int n = g_LevelCount;
   ArrayResize(g_LevelFormIndex, n + 1);
   ArrayResize(g_LevelPrice, n + 1);
   ArrayResize(g_LevelIsHigh, n + 1);
   ArrayResize(g_LevelSwept, n + 1);
   ArrayResize(g_LevelLineName, n + 1);

   g_LevelFormIndex[n] = i;
   g_LevelPrice[n]      = price;
   g_LevelIsHigh[n]      = isHigh;
   g_LevelSwept[n]       = false;
   g_LevelLineName[n]    = "";

   if(InpShowLevels)
     {
      string lineName = g_Prefix + "Lvl_" + (isHigh ? "H_" : "L_") + TimeToString(time[i], TIME_DATE | TIME_MINUTES)
                          + "_" + IntegerToString(n);

      datetime x2 = InpExtendLevelsUntilSwept ? time[i] : time[i] + (datetime)InpLevelExtendBars * PeriodSeconds(_Period);

      ObjectCreate(0, lineName, OBJ_TREND, 0, time[i], price, x2, price);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpLevelColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);

      g_LevelLineName[n] = lineName;
     }

   g_LevelCount++;

//--- keep the object count bounded on very long histories by dropping the
//--- single oldest tracked level whenever the cap is exceeded
   if(g_LevelCount > InpMaxLevelsToTrack)
      RemoveLevelAt(0);
  }

//+------------------------------------------------------------------+
//| Checks whether closed bar j sweeps level L, and raises the        |
//| signal (arrow + optional label) if it does                       |
//+------------------------------------------------------------------+
void CheckSweep(const int L, const int j, const datetime &time[],
                 const double &high[], const double &low[], const double &close[])
  {
   double level = g_LevelPrice[L];
   double minWick = InpMinWickPoints * _Point;

   if(g_LevelIsHigh[L])
     {
      //--- bearish sweep: price wicks above a swing high, then (optionally)
      //--- closes back below it — a liquidity grab above old highs
      double wick = high[j] - level;
      if(wick < minWick)
         return;
      if(InpRequireCloseBackInside && close[j] > level)
         return;

      RaiseSweepSignal(L, j, time, high[j], false);
     }
   else
     {
      //--- bullish sweep: price wicks below a swing low, then (optionally)
      //--- closes back above it — a liquidity grab below old lows
      double wick = level - low[j];
      if(wick < minWick)
         return;
      if(InpRequireCloseBackInside && close[j] < level)
         return;

      RaiseSweepSignal(L, j, time, low[j], true);
     }
  }

//+------------------------------------------------------------------+
//| Marks a level as swept, freezes/recolors its line, and draws the |
//| arrow (plus optional label) at the sweep bar                     |
//+------------------------------------------------------------------+
void RaiseSweepSignal(const int L, const int j, const datetime &time[], const double extremePrice, const bool bullish)
  {
   if(InpOneSweepPerLevel)
      g_LevelSwept[L] = true;

   if(InpShowLevels && g_LevelLineName[L] != "")
     {
      ObjectMove(0, g_LevelLineName[L], 1, time[j], g_LevelPrice[L]);
      ObjectSetInteger(0, g_LevelLineName[L], OBJPROP_COLOR, InpSweptLevelColor);
     }

   color arrowColor = bullish ? InpBullishSweepColor : InpBearishSweepColor;
   string arrowName = g_Prefix + "Arrow_" + IntegerToString(j) + "_" + IntegerToString(L);

   ObjectCreate(0, arrowName, bullish ? OBJ_ARROW_UP : OBJ_ARROW_DOWN, 0, time[j], extremePrice);
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, arrowColor);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, InpArrowWidth);
   ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, arrowName, OBJPROP_HIDDEN, true);

   if(InpShowLabels)
     {
      string labelName = g_Prefix + "Label_" + IntegerToString(j) + "_" + IntegerToString(L);
      string labelText = (bullish ? "Sweep " : "Sweep ") + DoubleToString(g_LevelPrice[L], _Digits);

      ObjectCreate(0, labelName, OBJ_TEXT, 0, time[j], extremePrice);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, arrowColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, bullish ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
     }
  }

//+------------------------------------------------------------------+
//| Removes the level at array index idx (deletes its line object    |
//| and shifts every later entry down by one)                        |
//+------------------------------------------------------------------+
void RemoveLevelAt(const int idx)
  {
   if(idx < 0 || idx >= g_LevelCount)
      return;

   if(g_LevelLineName[idx] != "")
      ObjectDelete(0, g_LevelLineName[idx]);

   for(int k = idx; k < g_LevelCount - 1; k++)
     {
      g_LevelFormIndex[k] = g_LevelFormIndex[k + 1];
      g_LevelPrice[k]      = g_LevelPrice[k + 1];
      g_LevelIsHigh[k]      = g_LevelIsHigh[k + 1];
      g_LevelSwept[k]       = g_LevelSwept[k + 1];
      g_LevelLineName[k]    = g_LevelLineName[k + 1];
     }

   g_LevelCount--;
   ArrayResize(g_LevelFormIndex, g_LevelCount);
   ArrayResize(g_LevelPrice, g_LevelCount);
   ArrayResize(g_LevelIsHigh, g_LevelCount);
   ArrayResize(g_LevelSwept, g_LevelCount);
   ArrayResize(g_LevelLineName, g_LevelCount);
  }
//+------------------------------------------------------------------+
