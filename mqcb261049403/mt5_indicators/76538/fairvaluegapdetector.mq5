//+------------------------------------------------------------------+
//|                                         FairValueGapDetector.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Detects 3-candle Fair Value Gaps (price imbalances) and draws them as "
#property description "rectangles that extend forward until price trades back through the gap "
#property description "(mitigation), at which point the box freezes and can be grayed out."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Detection Settings ==="
input int InpMinGapSizePoints = 50;   // Minimum Gap Size to Draw (points)
input int InpMaxGapsToShow    = 50;   // Maximum Gaps Kept on Chart (oldest removed first)

input group "=== Mitigation Behavior ==="
input bool InpExtendUntilMitigated = true;  // Extend Box Live Until Price Fills the Gap
input int  InpExtendBars           = 20;    // Fixed Extension (bars) — used only if not extending until mitigated
input bool InpHideMitigatedGaps    = false; // Delete a Gap's Box Once Mitigated (instead of graying it out)

input group "=== Box Style ==="
input color InpBullishColor   = clrLime;      // Bullish Gap Color
input color InpBearishColor   = clrRed;       // Bearish Gap Color
input color InpMitigatedColor = clrDimGray;   // Color Once a Gap Has Been Mitigated
input bool  InpFillBox        = true;         // Fill the Gap Box
input ENUM_LINE_STYLE InpBoxStyle = STYLE_SOLID; // Box Border Style
input int   InpBoxWidth       = 1;            // Box Border Width

//+------------------------------------------------------------------+
//| Global variables — one set of parallel arrays tracking every gap |
//| currently kept on the chart (both active and mitigated)          |
//+------------------------------------------------------------------+
string   g_Prefix = "FVG_";

datetime g_GapX1[];        // left edge (time of the middle candle of the 3-bar pattern)
double   g_GapTop[];       // top price of the gap zone
double   g_GapBottom[];    // bottom price of the gap zone
bool     g_GapBull[];      // true = bullish gap, false = bearish gap
bool     g_GapMitigated[]; // true once price has traded back through the zone
string   g_GapObjName[];   // chart object name for this gap's rectangle
int      g_GapCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMinGapSizePoints < 0)
     {
      Alert("FairValueGapDetector: 'Minimum Gap Size' cannot be negative.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMaxGapsToShow < 1)
     {
      Alert("FairValueGapDetector: 'Maximum Gaps Kept on Chart' must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Fair Value Gap Detector");

   g_GapCount = 0;
   ArrayResize(g_GapX1, 0);
   ArrayResize(g_GapTop, 0);
   ArrayResize(g_GapBottom, 0);
   ArrayResize(g_GapBull, 0);
   ArrayResize(g_GapMitigated, 0);
   ArrayResize(g_GapObjName, 0);

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
//--- a 3-candle pattern needs at least 3 closed bars, plus the currently
//--- forming bar makes 4 as a practical minimum
   if(rates_total < 4)
      return(0);

   if(prev_calculated == 0)
     {
      //--- full rebuild: drop everything and start clean, e.g. on first attach
      //--- or after a history reload
      ObjectsDeleteAll(0, g_Prefix);
      g_GapCount = 0;
      ArrayResize(g_GapX1, 0);
      ArrayResize(g_GapTop, 0);
      ArrayResize(g_GapBottom, 0);
      ArrayResize(g_GapBull, 0);
      ArrayResize(g_GapMitigated, 0);
      ArrayResize(g_GapObjName, 0);
     }

//--- detection and mitigation are only evaluated on fully closed bars, for
//--- stability (a still-forming candle's high/low can still change, which
//--- would otherwise cause gaps to flicker in and out of existence)
   int lastClosedIndex = rates_total - 2;

   if(lastClosedIndex >= 2)
     {
      int start = (prev_calculated == 0) ? 2 : MathMax(2, prev_calculated - 1);
      if(start > lastClosedIndex)
         start = lastClosedIndex + 1; // nothing new has closed since the last call

      for(int i = start; i <= lastClosedIndex; i++)
        {
         //--- 1) check this newly closed bar against every still-active gap —
         //--- cheap, since the active-gap list is normally small
         for(int g = 0; g < g_GapCount; g++)
           {
            if(g_GapMitigated[g])
               continue;

            if(low[i] <= g_GapTop[g] && high[i] >= g_GapBottom[g])
               MitigateGap(g, time[i]);
           }

         //--- 2) check whether bars (i-2, i-1, i) form a brand-new gap
         double top, bottom;
         bool   bullish;

         if(DetectGap(i, high, low, top, bottom, bullish))
           {
            long sizePoints = (_Point > 0) ? (long)MathRound((top - bottom) / _Point) : 0;
            if(sizePoints >= InpMinGapSizePoints)
               AddNewGap(i, time, top, bottom, bullish);
           }
        }
     }

//--- 3) live-extend every still-active gap's right edge up to the current
//--- (possibly still-forming) bar — a cheap O(active gaps) operation that
//--- runs on every tick regardless of whether a new bar closed
   if(InpExtendUntilMitigated)
     {
      datetime edge = time[rates_total - 1];
      for(int g = 0; g < g_GapCount; g++)
         if(!g_GapMitigated[g])
            ObjectMove(0, g_GapObjName[g], 1, edge, g_GapBottom[g]);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Checks whether bars (i-2, i-1, i) form a Fair Value Gap:          |
//| Bullish  — low[i]  > high[i-2]  (gap: high[i-2] .. low[i])       |
//| Bearish  — high[i] < low[i-2]   (gap: high[i] .. low[i-2])       |
//+------------------------------------------------------------------+
bool DetectGap(const int i, const double &high[], const double &low[],
                double &outTop, double &outBottom, bool &outBullish)
  {
   if(low[i] > high[i - 2])
     {
      outTop     = low[i];
      outBottom  = high[i - 2];
      outBullish = true;
      return(true);
     }

   if(high[i] < low[i - 2])
     {
      outTop     = low[i - 2];
      outBottom  = high[i];
      outBullish = false;
      return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//| Adds a newly detected gap: draws its rectangle and appends it to |
//| the tracking arrays, capping the total kept on chart              |
//+------------------------------------------------------------------+
void AddNewGap(const int i, const datetime &time[], const double top, const double bottom, const bool bullish)
  {
   datetime x1 = time[i - 1]; // the middle (impulsive) candle of the 3-bar pattern
   datetime x2;

   if(InpExtendUntilMitigated)
      x2 = time[i]; // will be pushed forward live every tick until mitigated
   else
      x2 = x1 + (datetime)InpExtendBars * PeriodSeconds(_Period);

   string objName = g_Prefix + (bullish ? "Bull_" : "Bear_") + TimeToString(x1, TIME_DATE | TIME_MINUTES)
                     + "_" + IntegerToString(g_GapCount);

   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, x1, top, x2, bottom);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, bullish ? InpBullishColor : InpBearishColor);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, InpBoxStyle);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, InpBoxWidth);
   ObjectSetInteger(0, objName, OBJPROP_FILL, InpFillBox);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);

   int n = g_GapCount;
   ArrayResize(g_GapX1, n + 1);
   ArrayResize(g_GapTop, n + 1);
   ArrayResize(g_GapBottom, n + 1);
   ArrayResize(g_GapBull, n + 1);
   ArrayResize(g_GapMitigated, n + 1);
   ArrayResize(g_GapObjName, n + 1);

   g_GapX1[n]        = x1;
   g_GapTop[n]        = top;
   g_GapBottom[n]     = bottom;
   g_GapBull[n]       = bullish;
   g_GapMitigated[n]  = false;
   g_GapObjName[n]    = objName;
   g_GapCount++;

//--- keep the object count bounded on very long histories by dropping the
//--- single oldest tracked gap whenever the cap is exceeded
   if(g_GapCount > InpMaxGapsToShow)
      RemoveGapAt(0);
  }

//+------------------------------------------------------------------+
//| Freezes a gap's right edge at the bar where it was mitigated, and|
//| either grays it out or deletes it, per InpHideMitigatedGaps       |
//+------------------------------------------------------------------+
void MitigateGap(const int g, const datetime mitigationTime)
  {
   g_GapMitigated[g] = true;

   if(InpHideMitigatedGaps)
     {
      ObjectDelete(0, g_GapObjName[g]);
      return;
     }

   ObjectMove(0, g_GapObjName[g], 1, mitigationTime, g_GapBottom[g]);
   ObjectSetInteger(0, g_GapObjName[g], OBJPROP_COLOR, InpMitigatedColor);
  }

//+------------------------------------------------------------------+
//| Removes the gap at array index idx (deletes its chart object and |
//| shifts every later entry down by one)                            |
//+------------------------------------------------------------------+
void RemoveGapAt(const int idx)
  {
   if(idx < 0 || idx >= g_GapCount)
      return;

   ObjectDelete(0, g_GapObjName[idx]);

   for(int k = idx; k < g_GapCount - 1; k++)
     {
      g_GapX1[k]        = g_GapX1[k + 1];
      g_GapTop[k]        = g_GapTop[k + 1];
      g_GapBottom[k]     = g_GapBottom[k + 1];
      g_GapBull[k]       = g_GapBull[k + 1];
      g_GapMitigated[k]  = g_GapMitigated[k + 1];
      g_GapObjName[k]    = g_GapObjName[k + 1];
     }

   g_GapCount--;
   ArrayResize(g_GapX1, g_GapCount);
   ArrayResize(g_GapTop, g_GapCount);
   ArrayResize(g_GapBottom, g_GapCount);
   ArrayResize(g_GapBull, g_GapCount);
   ArrayResize(g_GapMitigated, g_GapCount);
   ArrayResize(g_GapObjName, g_GapCount);
  }
//+------------------------------------------------------------------+
