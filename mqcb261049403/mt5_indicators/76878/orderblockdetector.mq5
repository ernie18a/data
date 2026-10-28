//+------------------------------------------------------------------+
//|                                          OrderBlockDetector.mq5  |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                       https://www.mql5.com       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Detects order blocks — the last opposing candle before an impulsive move "
#property description "that breaks market structure — and draws them as zones that extend live "
#property description "until price returns and mitigates them."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                  |
//+------------------------------------------------------------------+
input group "=== Structure Detection ==="
input int    InpSwingLookback          = 5;   // Swing Lookback (bars on each side to confirm a pivot)
input int    InpMinBreakPoints         = 30;  // Minimum Break Distance Beyond Swing Level (points)
input double InpMinImpulseBodyPercent  = 50.0; // Minimum Body-to-Range % for a Valid Impulse Candle
input int    InpMaxSearchBarsForOB     = 10;  // Max Bars Searched Back for the Order-Block Candle

input group "=== Order Block Zone ==="
input bool InpUseBodyOnly       = false; // Use Candle Body Only (instead of full wick range)
input int  InpMinZoneSizePoints = 30;    // Minimum Zone Size to Draw (points)
input int  InpMaxOBsToTrack     = 30;    // Maximum Order Blocks Kept on Chart (oldest removed first)

input group "=== Mitigation Behavior ==="
input bool InpExtendUntilMitigated          = true;  // Extend Box Live Until Price Mitigates It
input int  InpExtendBars                    = 40;    // Fixed Extension (bars) — used only if not extending until mitigated
input bool InpRequireFullCloseForMitigation = false;  // Require a Close Through the Zone (not just a touch)
input bool InpHideMitigatedOBs              = false;  // Delete a Block's Box Once Mitigated (instead of graying it out)

input group "=== Colors & Style ==="
input color InpBullishOBColor  = clrLime;    // Bullish Order Block Color
input color InpBearishOBColor  = clrRed;     // Bearish Order Block Color
input color InpMitigatedColor  = clrDimGray; // Color Once a Block Has Been Mitigated
input bool  InpFillBox         = true;       // Fill the Order Block Box
input ENUM_LINE_STYLE InpBoxStyle = STYLE_SOLID; // Box Border Style
input int   InpBoxWidth        = 1;          // Box Border Width
input bool  InpShowLabels      = true;       // Show a Label With the Zone Price

//+------------------------------------------------------------------+
//| Global variables — parallel arrays tracking every order block    |
//| currently kept on the chart                                      |
//+------------------------------------------------------------------+
string g_Prefix = "OB_";

int    g_ObFormIndex[]; // bar index of the order-block candle itself
double g_ObTop[];
double g_ObBottom[];
bool   g_ObBullish[];
bool   g_ObMitigated[];
string g_ObName[];
int    g_ObCount = 0;

//--- the most recently confirmed swing high/low that has not yet been broken
//--- ("pending" — a break consumes it so the same level cannot re-trigger)
double g_PendingHighPrice = 0.0;
int    g_PendingHighIndex = -1;
bool   g_PendingHighValid = false;

double g_PendingLowPrice = 0.0;
int    g_PendingLowIndex = -1;
bool   g_PendingLowValid = false;

int g_LastConfirmedPivotIndex = -1; // last bar index already checked for a new swing pivot
int g_LastProcessedIndex      = -1; // last closed bar index already checked for breaks/mitigation

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwingLookback < 1)
     {
      Alert("OrderBlockDetector: 'Swing Lookback' must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMaxOBsToTrack < 1)
     {
      Alert("OrderBlockDetector: 'Maximum Order Blocks Kept on Chart' must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMinImpulseBodyPercent < 0.0 || InpMinImpulseBodyPercent > 100.0)
     {
      Alert("OrderBlockDetector: 'Minimum Body-to-Range %' must be between 0 and 100.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Order Block Detector");

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
//| Clears all tracked order blocks, pending swing state, and chart  |
//| objects — used on first run and whenever the terminal forces a   |
//| full recalculation                                                |
//+------------------------------------------------------------------+
void ResetState()
  {
   ObjectsDeleteAll(0, g_Prefix);

   g_ObCount = 0;
   ArrayResize(g_ObFormIndex, 0);
   ArrayResize(g_ObTop, 0);
   ArrayResize(g_ObBottom, 0);
   ArrayResize(g_ObBullish, 0);
   ArrayResize(g_ObMitigated, 0);
   ArrayResize(g_ObName, 0);

   g_PendingHighValid = false;
   g_PendingLowValid  = false;

   g_LastConfirmedPivotIndex = InpSwingLookback - 1;
   g_LastProcessedIndex      = -1;
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
//--- once InpSwingLookback bars exist after it, so only the newly
//--- confirmable indices since the last call are ever checked, never the
//--- full history
   int confirmIndex = rates_total - 1 - InpSwingLookback;

   for(int i = g_LastConfirmedPivotIndex + 1; i <= confirmIndex; i++)
     {
      if(i - InpSwingLookback < 0)
         continue;

      if(IsSwingHigh(i, high))
        {
         g_PendingHighPrice = high[i];
         g_PendingHighIndex = i;
         g_PendingHighValid = true;
        }

      if(IsSwingLow(i, low))
        {
         g_PendingLowPrice = low[i];
         g_PendingLowIndex = i;
         g_PendingLowValid = true;
        }
     }

   if(confirmIndex > g_LastConfirmedPivotIndex)
      g_LastConfirmedPivotIndex = confirmIndex;

//--- 2) structure-break detection, order-block creation, and mitigation
//--- checks — evaluated only on fully closed bars for stability (a
//--- still-forming candle's open/high/low/close can still change)
   int lastClosedIndex = rates_total - 2;

   for(int j = g_LastProcessedIndex + 1; j <= lastClosedIndex; j++)
     {
      //--- check this newly closed bar against every still-active order
      //--- block — cheap, since the active-block list is normally small
      for(int L = 0; L < g_ObCount; L++)
        {
         if(g_ObMitigated[L])
            continue;
         if(g_ObFormIndex[L] >= j)
            continue; // the block must already exist before the bar being checked

         CheckMitigation(L, j, time, high, low, close);
        }

      //--- bullish break of structure: close pushes above the pending swing high
      if(g_PendingHighValid && (close[j] - g_PendingHighPrice) >= InpMinBreakPoints * _Point)
        {
         if(BodyPercent(j, open, high, low, close) >= InpMinImpulseBodyPercent)
           {
            int searchFloor = MathMax(g_PendingHighIndex, j - InpMaxSearchBarsForOB);
            int obIdx = FindLastDownCandle(j, searchFloor, open, close);
            if(obIdx != -1)
               TryAddOrderBlock(obIdx, j, time, open, high, low, close, true);
           }
         g_PendingHighValid = false; // the level is broken either way — consumed
        }

      //--- bearish break of structure: close pushes below the pending swing low
      if(g_PendingLowValid && (g_PendingLowPrice - close[j]) >= InpMinBreakPoints * _Point)
        {
         if(BodyPercent(j, open, high, low, close) >= InpMinImpulseBodyPercent)
           {
            int searchFloor = MathMax(g_PendingLowIndex, j - InpMaxSearchBarsForOB);
            int obIdx = FindLastUpCandle(j, searchFloor, open, close);
            if(obIdx != -1)
               TryAddOrderBlock(obIdx, j, time, open, high, low, close, false);
           }
         g_PendingLowValid = false; // the level is broken either way — consumed
        }
     }

   if(lastClosedIndex > g_LastProcessedIndex)
      g_LastProcessedIndex = lastClosedIndex;

//--- 3) live-extend every still-active block's right edge up to the current
//--- (possibly still-forming) bar — a cheap O(active blocks) operation that
//--- runs on every tick regardless of whether a new bar closed
   if(InpExtendUntilMitigated)
     {
      datetime edge = time[rates_total - 1];
      for(int L = 0; L < g_ObCount; L++)
         if(!g_ObMitigated[L])
            ObjectMove(0, g_ObName[L], 1, edge, g_ObBottom[L]);
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
//| Returns bar i's body size as a percentage of its total range,    |
//| used to filter out weak/doji "breaks" that shouldn't count as a  |
//| genuine impulse                                                   |
//+------------------------------------------------------------------+
double BodyPercent(const int i, const double &open[], const double &high[], const double &low[], const double &close[])
  {
   double range = high[i] - low[i];
   if(range <= 0.0)
      return(0.0);
   return(MathAbs(close[i] - open[i]) / range * 100.0);
  }

//+------------------------------------------------------------------+
//| Searches backward from breakIndex-1 down to searchFloor for the  |
//| most recent down-closing candle (the bullish order block)        |
//+------------------------------------------------------------------+
int FindLastDownCandle(const int breakIndex, const int searchFloor, const double &open[], const double &close[])
  {
   for(int k = breakIndex - 1; k >= searchFloor && k >= 0; k--)
      if(close[k] < open[k])
         return(k);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Searches backward from breakIndex-1 down to searchFloor for the  |
//| most recent up-closing candle (the bearish order block)          |
//+------------------------------------------------------------------+
int FindLastUpCandle(const int breakIndex, const int searchFloor, const double &open[], const double &close[])
  {
   for(int k = breakIndex - 1; k >= searchFloor && k >= 0; k--)
      if(close[k] > open[k])
         return(k);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Builds the zone for a candidate order block, applies the minimum |
//| size filter, and draws it if it passes                           |
//+------------------------------------------------------------------+
void TryAddOrderBlock(const int obIdx, const int breakIdx, const datetime &time[],
                       const double &open[], const double &high[], const double &low[], const double &close[],
                       const bool bullish)
  {
   double top, bottom;

   if(InpUseBodyOnly)
     {
      top    = MathMax(open[obIdx], close[obIdx]);
      bottom = MathMin(open[obIdx], close[obIdx]);
     }
   else
     {
      top    = high[obIdx];
      bottom = low[obIdx];
     }

   long sizePoints = (_Point > 0) ? (long)MathRound((top - bottom) / _Point) : 0;
   if(sizePoints < InpMinZoneSizePoints)
      return;

   datetime x1 = time[obIdx];
   datetime x2 = InpExtendUntilMitigated ? time[breakIdx] : x1 + (datetime)InpExtendBars * PeriodSeconds(_Period);

   string objName = g_Prefix + (bullish ? "Bull_" : "Bear_") + TimeToString(x1, TIME_DATE | TIME_MINUTES)
                     + "_" + IntegerToString(g_ObCount);

   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, x1, top, x2, bottom);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, bullish ? InpBullishOBColor : InpBearishOBColor);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, InpBoxStyle);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, InpBoxWidth);
   ObjectSetInteger(0, objName, OBJPROP_FILL, InpFillBox);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);

   if(InpShowLabels)
     {
      string labelName = objName + "_Lbl";
      string labelText = (bullish ? "Bull OB " : "Bear OB ") + DoubleToString(bullish ? bottom : top, _Digits);

      ObjectCreate(0, labelName, OBJ_TEXT, 0, x1, bullish ? bottom : top);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, bullish ? InpBullishOBColor : InpBearishOBColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, bullish ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
     }

   int n = g_ObCount;
   ArrayResize(g_ObFormIndex, n + 1);
   ArrayResize(g_ObTop, n + 1);
   ArrayResize(g_ObBottom, n + 1);
   ArrayResize(g_ObBullish, n + 1);
   ArrayResize(g_ObMitigated, n + 1);
   ArrayResize(g_ObName, n + 1);

   g_ObFormIndex[n] = obIdx;
   g_ObTop[n]        = top;
   g_ObBottom[n]     = bottom;
   g_ObBullish[n]    = bullish;
   g_ObMitigated[n]  = false;
   g_ObName[n]       = objName;
   g_ObCount++;

//--- keep the object count bounded on very long histories by dropping the
//--- single oldest tracked block whenever the cap is exceeded
   if(g_ObCount > InpMaxOBsToTrack)
      RemoveOrderBlockAt(0);
  }

//+------------------------------------------------------------------+
//| Checks whether closed bar j mitigates order block L, and freezes |
//| / recolors (or deletes) its box if it does                       |
//+------------------------------------------------------------------+
void CheckMitigation(const int L, const int j, const datetime &time[], const double &high[], const double &low[], const double &close[])
  {
   double top    = g_ObTop[L];
   double bottom = g_ObBottom[L];

   bool touched = (low[j] <= top && high[j] >= bottom);
   if(!touched)
      return;

   if(InpRequireFullCloseForMitigation)
     {
      bool closedInside = (close[j] <= top && close[j] >= bottom);
      if(!closedInside)
         return;
     }

   g_ObMitigated[L] = true;

   string labelName = g_ObName[L] + "_Lbl";

   if(InpHideMitigatedOBs)
     {
      ObjectDelete(0, g_ObName[L]);
      ObjectDelete(0, labelName);
      return;
     }

   // freeze the right edge exactly at the bar where mitigation happened,
   // instead of leaving it at whatever the last live-extend tick reached
   ObjectMove(0, g_ObName[L], 1, time[j], bottom);
   ObjectSetInteger(0, g_ObName[L], OBJPROP_COLOR, InpMitigatedColor);
   if(ObjectFind(0, labelName) >= 0)
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, InpMitigatedColor);
  }

//+------------------------------------------------------------------+
//| Removes the order block at array index idx (deletes its box and  |
//| label objects and shifts every later entry down by one)          |
//+------------------------------------------------------------------+
void RemoveOrderBlockAt(const int idx)
  {
   if(idx < 0 || idx >= g_ObCount)
      return;

   ObjectDelete(0, g_ObName[idx]);
   ObjectDelete(0, g_ObName[idx] + "_Lbl");

   for(int k = idx; k < g_ObCount - 1; k++)
     {
      g_ObFormIndex[k] = g_ObFormIndex[k + 1];
      g_ObTop[k]        = g_ObTop[k + 1];
      g_ObBottom[k]     = g_ObBottom[k + 1];
      g_ObBullish[k]    = g_ObBullish[k + 1];
      g_ObMitigated[k]  = g_ObMitigated[k + 1];
      g_ObName[k]       = g_ObName[k + 1];
     }

   g_ObCount--;
   ArrayResize(g_ObFormIndex, g_ObCount);
   ArrayResize(g_ObTop, g_ObCount);
   ArrayResize(g_ObBottom, g_ObCount);
   ArrayResize(g_ObBullish, g_ObCount);
   ArrayResize(g_ObMitigated, g_ObCount);
   ArrayResize(g_ObName, g_ObCount);
  }
//+------------------------------------------------------------------+
