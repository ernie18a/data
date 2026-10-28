//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone. - Optimized 2025"
#property link      "mql5.com"
#property version   "2.0"
#property description "Auto Trendline with Breakout Detection & Auto-Adjust"

#property strict
//---
#property indicator_chart_window
//---
enum TREND_DETECTION_MODE {
   DUAL_PIVOT,      // Mode A: Dual Pivot Detection
   SLOPE_ADAPTIVE   // Mode B: Adaptive Slope Analysis
};
//+------------------------------------------------------------------+
//| Price Level Point Structure                                      |
//+------------------------------------------------------------------+
class CPriceLevel {
   private:
      double m_priceValue;
      datetime m_timestamp;
   public:
      CPriceLevel() : m_priceValue(0), m_timestamp(0) {}
      CPriceLevel(const double val, const datetime stamp) : m_priceValue(val), m_timestamp(stamp) {}
      ~CPriceLevel() {}
      
      void UpdateLevel(const double val, const datetime stamp) {
         m_priceValue = val;
         m_timestamp = stamp;
      }
      
      bool operator==(const CPriceLevel &compare) const {
         return m_priceValue == compare.m_priceValue && m_timestamp == compare.m_timestamp;
      }
      
      bool operator!=(const CPriceLevel &compare) const {
         return !operator==(compare);
      }
      
      void operator=(const CPriceLevel &source) {
         m_priceValue = source.m_priceValue;
         m_timestamp = source.m_timestamp;
      }
      
      double Price() const { return m_priceValue; }
      datetime Timestamp() const { return m_timestamp; }
      bool IsActive() const { return m_priceValue != 0 && m_timestamp != 0; }
      void Reset() { m_priceValue = 0; m_timestamp = 0; }
};
//+------------------------------------------------------------------+
//| Breakout History Structure                                        |
//+------------------------------------------------------------------+
struct SBreakoutEvent {
   datetime breakTime;
   double breakPrice;
   bool isSupport;        // true = support break, false = resistance break
   string trendlineId;
};
//+------------------------------------------------------------------+
//| Global State Variables                                           |
//+------------------------------------------------------------------+
CPriceLevel g_activeLowerAnchor, g_activeLowerTrigger;
CPriceLevel g_activeUpperAnchor, g_activeUpperTrigger;
CPriceLevel g_cachedLowerAnchor, g_cachedLowerTrigger;
CPriceLevel g_cachedUpperAnchor, g_cachedUpperTrigger;

// Historical trendlines storage
CPriceLevel g_historyLowerAnchor[], g_historyLowerTrigger[];
CPriceLevel g_historyUpperAnchor[], g_historyUpperTrigger[];
int g_historyCount = 0;

// Breakout detection variables
bool g_lastLowerBreakout = false;
bool g_lastUpperBreakout = false;
SBreakoutEvent g_breakoutHistory[];
//+------------------------------------------------------------------+
//| User Configuration Parameters                                    |
//+------------------------------------------------------------------+
input TREND_DETECTION_MODE DetectionMethod = SLOPE_ADAPTIVE;  // Detection Algorithm
input int                  PrimaryLookback = 35;              // Primary Pivot Lookback
input int                  SecondaryLookback = 5;             // Secondary Pivot Lookback
input int                  BarsFromEdge = 8;                  // Bars Offset From Edge
input bool                 IncludePreviousBar = true;         // Include Previous Bar Analysis
//---
input group "=== Breakout Detection Settings ==="
input bool                 EnableBreakoutDetection = true;    // Enable Breakout Detection
input double               BreakoutThreshold = 5;             // Breakout Threshold (pips)
input int                  BreakoutConfirmBars = 2;           // Confirmation Bars
input bool                 AutoAdjustOnBreak = true;          // Auto-Adjust After Break
input bool                 ShowBreakoutAlert = true;          // Show Alert on Breakout
input bool                 ConvertToSupRes = true;            // Convert Support <-> Resistance
//---
input group "=== Display Settings ==="
input int                  TrendlineThickness = 2;            // Line Thickness
input color                LowerBoundColor = clrLime;         // Lower Boundary Color
input color                UpperBoundColor = clrOrangeRed;    // Upper Boundary Color
input ENUM_LINE_STYLE      TrendlinePattern = STYLE_SOLID;    // Line Pattern Style
input bool                 ProjectForward = false;            // Project Lines Forward
//---
input group "=== History Display ==="
input bool                 ShowHistoricalLines = true;        // Show Historical Trendlines
input int                  MaxHistoryLines = 3;               // Max Historical Lines to Show
input color                HistoryLowerColor = clrDarkGreen;  // History Lower Color
input color                HistoryUpperColor = clrDarkRed;    // History Upper Color
input ENUM_LINE_STYLE      HistoryLineStyle = STYLE_DOT;      // History Line Style
input int                  HistoryLineWidth = 1;              // History Line Width
//---
input group "=== Breakout Markers ==="
input bool                 ShowBreakoutMarkers = true;        // Show Breakout Markers
input color                BreakoutArrowColor = clrYellow;    // Breakout Arrow Color
input int                  ArrowSize = 2;                     // Arrow Size
//---
input string               IdentifierPrefix = "DynamicTrend"; // Object Identifier
//--- Internal System Variables
int g_minimumDataPoints;
double g_pointValue;
int g_breakoutConfirmCounter = 0;
//+------------------------------------------------------------------+
//| Indicator Initialization Handler                                 |
//+------------------------------------------------------------------+
int OnInit() {
   // Parameter Validation
   if (PrimaryLookback < 2) {
      Print("Alert: Primary lookback must be minimum 2 bars");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if (SecondaryLookback < 1) {
      Print("Alert: Secondary lookback must be minimum 1 bar");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if (BarsFromEdge < 0) {
      Print("Alert: Edge offset cannot be negative");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if (MaxHistoryLines < 0) {
      Print("Alert: Max history lines cannot be negative");
      return(INIT_PARAMETERS_INCORRECT);
   }
  
   g_minimumDataPoints = PrimaryLookback * 2 + MathMax(SecondaryLookback, BarsFromEdge) * 2;
   
   // Calculate point value for breakout threshold
   g_pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if (g_pointValue == 0) g_pointValue = 0.00001;
   
   // Initialize history arrays
   ArrayResize(g_historyLowerAnchor, MaxHistoryLines);
   ArrayResize(g_historyLowerTrigger, MaxHistoryLines);
   ArrayResize(g_historyUpperAnchor, MaxHistoryLines);
   ArrayResize(g_historyUpperTrigger, MaxHistoryLines);
   ArrayResize(g_breakoutHistory, 100);
  
   // Configure Indicator Display Name
   string displayLabel = StringFormat("SmartTrend(%s)%s",
                         DetectionMethod == SLOPE_ADAPTIVE ? "Adaptive" : "Dual",
                         EnableBreakoutDetection ? "+Breakout" : "");
   IndicatorSetString(INDICATOR_SHORTNAME, displayLabel);
  
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator Cleanup Handler                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, IdentifierPrefix);
   ArrayFree(g_historyLowerAnchor);
   ArrayFree(g_historyLowerTrigger);
   ArrayFree(g_historyUpperAnchor);
   ArrayFree(g_historyUpperTrigger);
   ArrayFree(g_breakoutHistory);
}
//+------------------------------------------------------------------+
//| Main Calculation Loop                                            |
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
                const int &spread[]) {
  
   // Validate Sufficient Data
   if (rates_total < g_minimumDataPoints) {
      return(0);
   }
  
   // Skip Recalculation If No New Bar
   if (prev_calculated == rates_total) {
      return(rates_total);
   }
  
   // Check for breakout BEFORE updating trendlines
   if (EnableBreakoutDetection && prev_calculated > 0) {
      bool lowerBreak = DetectBreakout(rates_total, time, close, true);
      bool upperBreak = DetectBreakout(rates_total, time, close, false);
      
      if (lowerBreak || upperBreak) {
         if (AutoAdjustOnBreak) {
            // Save current trendlines to history before recalculating
            SaveToHistory(lowerBreak, upperBreak);
         }
      }
   }
  
   // Cache Current State
   g_cachedLowerAnchor = g_activeLowerAnchor;
   g_cachedLowerTrigger = g_activeLowerTrigger;
   g_cachedUpperAnchor = g_activeUpperAnchor;
   g_cachedUpperTrigger = g_activeUpperTrigger;
  
   // Execute Detection Algorithm
   switch (DetectionMethod) {
      case SLOPE_ADAPTIVE:
         ExecuteSlopeAnalysis(rates_total, time, high, low);
         break;
        
      case DUAL_PIVOT:
      default:
         ExecuteDualPivotScan(rates_total, time, high, low);
         break;
   }
  
   // Check For State Changes
   bool stateChanged = (g_activeLowerAnchor != g_cachedLowerAnchor ||
                        g_activeLowerTrigger != g_cachedLowerTrigger ||
                        g_activeUpperAnchor != g_cachedUpperAnchor ||
                        g_activeUpperTrigger != g_cachedUpperTrigger);
  
   if (stateChanged) {
      // Render Historical Lines First (so they appear behind)
      if (ShowHistoricalLines) {
         RenderHistoricalLines();
      }
      
      // Render Active Lower Boundary
      if (g_activeLowerAnchor.IsActive() && g_activeLowerTrigger.IsActive()) {
         RenderTrendline("LowerBound", g_activeLowerTrigger, g_activeLowerAnchor, 
                        LowerBoundColor, TrendlinePattern, TrendlineThickness);
      }
      
      // Render Active Upper Boundary
      if (g_activeUpperAnchor.IsActive() && g_activeUpperTrigger.IsActive()) {
         RenderTrendline("UpperBound", g_activeUpperTrigger, g_activeUpperAnchor, 
                        UpperBoundColor, TrendlinePattern, TrendlineThickness);
      }
   }
  
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Detect Breakout                                                  |
//+------------------------------------------------------------------+
bool DetectBreakout(const int totalBars, const datetime &time[], 
                    const double &close[], bool checkLower) {
   
   CPriceLevel anchor = checkLower ? g_activeLowerAnchor : g_activeUpperAnchor;
   CPriceLevel trigger = checkLower ? g_activeLowerTrigger : g_activeUpperTrigger;
   
   if (!anchor.IsActive() || !trigger.IsActive()) {
      return false;
   }
   
   // Calculate trendline price at current bar
   int currentIdx = totalBars - 2; // Last completed bar
   datetime currentTime = time[currentIdx];
   
   // Find bar indices for trendline points
   int anchorIdx = iBarShift(_Symbol, PERIOD_CURRENT, anchor.Timestamp());
   int triggerIdx = iBarShift(_Symbol, PERIOD_CURRENT, trigger.Timestamp());
   
   if (anchorIdx < 0 || triggerIdx < 0) return false;
   
   // Calculate trendline slope
   double priceRange = anchor.Price() - trigger.Price();
   int timeRange = anchorIdx - triggerIdx;
   
   if (timeRange == 0) return false;
   
   double slope = priceRange / timeRange;
   
   // Calculate expected price at current bar
   int barsFromTrigger = currentIdx - triggerIdx;
   double expectedPrice = trigger.Price() + (slope * barsFromTrigger);
   
   // Convert threshold to price
   double thresholdPrice = BreakoutThreshold * g_pointValue * 10;
   
   bool breakDetected = false;
   
   if (checkLower) {
      // Support breakout - price closes below line
      if (close[currentIdx] < (expectedPrice - thresholdPrice)) {
         breakDetected = true;
      }
   } else {
      // Resistance breakout - price closes above line
      if (close[currentIdx] > (expectedPrice + thresholdPrice)) {
         breakDetected = true;
      }
   }
   
   if (breakDetected) {
      // Mark breakout event
      if (ShowBreakoutMarkers) {
         DrawBreakoutMarker(currentTime, close[currentIdx], checkLower);
      }
      
      if (ShowBreakoutAlert) {
         string alertMsg = StringFormat("%s BREAKOUT at %.5f on %s", 
                                       checkLower ? "SUPPORT" : "RESISTANCE",
                                       close[currentIdx],
                                       _Symbol);
         Alert(alertMsg);
      }
      
      // Record breakout event
      RecordBreakout(currentTime, close[currentIdx], checkLower);
      
      return true;
   }
   
   return false;
}
//+------------------------------------------------------------------+
//| Save Current Trendlines to History                               |
//+------------------------------------------------------------------+
void SaveToHistory(bool saveLower, bool saveUpper) {
   if (!ShowHistoricalLines) return;
   
   // Shift existing history
   for (int i = MaxHistoryLines - 1; i > 0; i--) {
      if (saveLower) {
         g_historyLowerAnchor[i] = g_historyLowerAnchor[i-1];
         g_historyLowerTrigger[i] = g_historyLowerTrigger[i-1];
      }
      if (saveUpper) {
         g_historyUpperAnchor[i] = g_historyUpperAnchor[i-1];
         g_historyUpperTrigger[i] = g_historyUpperTrigger[i-1];
      }
   }
   
   // Save current to position 0
   if (saveLower && g_activeLowerAnchor.IsActive()) {
      g_historyLowerAnchor[0] = g_activeLowerAnchor;
      g_historyLowerTrigger[0] = g_activeLowerTrigger;
   }
   
   if (saveUpper && g_activeUpperAnchor.IsActive()) {
      g_historyUpperAnchor[0] = g_activeUpperAnchor;
      g_historyUpperTrigger[0] = g_activeUpperTrigger;
   }
   
   g_historyCount = MathMin(g_historyCount + 1, MaxHistoryLines);
}
//+------------------------------------------------------------------+
//| Render Historical Trendlines                                     |
//+------------------------------------------------------------------+
void RenderHistoricalLines() {
   for (int i = 0; i < g_historyCount && i < MaxHistoryLines; i++) {
      // Render historical lower trendline
      if (g_historyLowerAnchor[i].IsActive() && g_historyLowerTrigger[i].IsActive()) {
         string name = StringFormat("HistoryLower_%d", i);
         RenderTrendline(name, g_historyLowerTrigger[i], g_historyLowerAnchor[i],
                        HistoryLowerColor, HistoryLineStyle, HistoryLineWidth);
      }
      
      // Render historical upper trendline
      if (g_historyUpperAnchor[i].IsActive() && g_historyUpperTrigger[i].IsActive()) {
         string name = StringFormat("HistoryUpper_%d", i);
         RenderTrendline(name, g_historyUpperTrigger[i], g_historyUpperAnchor[i],
                        HistoryUpperColor, HistoryLineStyle, HistoryLineWidth);
      }
   }
}
//+------------------------------------------------------------------+
//| Draw Breakout Marker                                             |
//+------------------------------------------------------------------+
void DrawBreakoutMarker(datetime breakTime, double breakPrice, bool isSupport) {
   static int breakoutCounter = 0;
   breakoutCounter++;
   
   string objName = IdentifierPrefix + "-Break-" + IntegerToString(breakoutCounter);
   
   // Create arrow
   int arrowCode = isSupport ? 234 : 233; // Down arrow for support break, up for resistance
   
   ObjectCreate(0, objName, OBJ_ARROW, 0, breakTime, breakPrice);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, BreakoutArrowColor);
   ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrowCode);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, ArrowSize);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   string tooltip = StringFormat("Breakout: %s broken at %.5f", 
                                isSupport ? "Support" : "Resistance", breakPrice);
   ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
}
//+------------------------------------------------------------------+
//| Record Breakout Event                                            |
//+------------------------------------------------------------------+
void RecordBreakout(datetime breakTime, double breakPrice, bool isSupport) {
   int size = ArraySize(g_breakoutHistory);
   
   // Shift array if full
   if (size >= 100) {
      for (int i = 0; i < 99; i++) {
         g_breakoutHistory[i] = g_breakoutHistory[i+1];
      }
      size = 99;
   }
   
   // Add new event
   g_breakoutHistory[size].breakTime = breakTime;
   g_breakoutHistory[size].breakPrice = breakPrice;
   g_breakoutHistory[size].isSupport = isSupport;
   g_breakoutHistory[size].trendlineId = isSupport ? "LowerBound" : "UpperBound";
}
//+------------------------------------------------------------------+
//| Slope-Based Adaptive Analysis                                    |
//+------------------------------------------------------------------+
void ExecuteSlopeAnalysis(const int totalBars, const datetime &time[],
                          const double &high[], const double &low[]) {
   int anchorIdx, triggerIdx;
   double gradient, testGradient;
  
   //--- Lower Boundary Detection
   anchorIdx = LocatePivotPoint(totalBars - PrimaryLookback - 2, PrimaryLookback,
                                 low, g_minimumDataPoints, true);
   if (anchorIdx > 0) {
      g_activeLowerAnchor.UpdateLevel(low[anchorIdx], time[anchorIdx]);
      
      triggerIdx = totalBars - BarsFromEdge - 2;
      gradient = (low[triggerIdx] - low[anchorIdx]) / (triggerIdx - anchorIdx);
      
      int scanStart = IncludePreviousBar ? anchorIdx : anchorIdx + 1;
      
      for (int i = triggerIdx - 1; i > scanStart; i--) {
         testGradient = (low[i] - g_activeLowerAnchor.Price()) / (i - scanStart);
         if (testGradient < gradient) {
            gradient = testGradient;
            triggerIdx = i;
         }
      }
      g_activeLowerTrigger.UpdateLevel(low[triggerIdx], time[triggerIdx]);
   }
  
   //--- Upper Boundary Detection
   anchorIdx = LocatePivotPoint(totalBars - PrimaryLookback - 2, PrimaryLookback,
                                high, g_minimumDataPoints, false);
   if (anchorIdx > 0) {
      g_activeUpperAnchor.UpdateLevel(high[anchorIdx], time[anchorIdx]);
      
      triggerIdx = totalBars - BarsFromEdge - 2;
      gradient = (high[anchorIdx] - high[triggerIdx]) / (triggerIdx - anchorIdx);
      
      int scanStart = IncludePreviousBar ? anchorIdx : anchorIdx + 1;
      
      for (int i = triggerIdx - 1; i > scanStart; i--) {
         testGradient = (g_activeUpperAnchor.Price() - high[i]) / (i - scanStart);
         if (testGradient < gradient) {
            gradient = testGradient;
            triggerIdx = i;
         }
      }
      g_activeUpperTrigger.UpdateLevel(high[triggerIdx], time[triggerIdx]);
   }
}
//+------------------------------------------------------------------+
//| Dual Pivot Detection Method                                      |
//+------------------------------------------------------------------+
void ExecuteDualPivotScan(const int totalBars, const datetime &time[],
                          const double &high[], const double &low[]) {
   int anchorIdx, triggerIdx;
  
   //--- Lower Boundary Scan
   triggerIdx = LocatePivotPoint(totalBars - SecondaryLookback - 2, SecondaryLookback,
                                  low, g_minimumDataPoints, true);
   if (triggerIdx > 0) {
      g_activeLowerTrigger.UpdateLevel(low[triggerIdx], time[triggerIdx]);
      
      anchorIdx = LocatePivotPoint(triggerIdx - SecondaryLookback, PrimaryLookback,
                                   low, g_minimumDataPoints, true);
      if (anchorIdx > 0) {
         g_activeLowerAnchor.UpdateLevel(low[anchorIdx], time[anchorIdx]);
      }
   }
  
   //--- Upper Boundary Scan
   triggerIdx = LocatePivotPoint(totalBars - SecondaryLookback - 2, SecondaryLookback,
                                  high, g_minimumDataPoints, false);
   if (triggerIdx > 0) {
      g_activeUpperTrigger.UpdateLevel(high[triggerIdx], time[triggerIdx]);
      
      anchorIdx = LocatePivotPoint(triggerIdx - SecondaryLookback, PrimaryLookback,
                                   high, g_minimumDataPoints, false);
      if (anchorIdx > 0) {
         g_activeUpperAnchor.UpdateLevel(high[anchorIdx], time[anchorIdx]);
      }
   }
}
//+------------------------------------------------------------------+
//| Locate Pivot Point In Price Array                                |
//+------------------------------------------------------------------+
int LocatePivotPoint(int startIndex, int radius, const double &prices[],
                     int minIndex, bool searchLow) {
   for (int idx = startIndex; idx > minIndex; idx--) {
      if (searchLow) {
         if (IsValleyPoint(idx, radius, prices)) return idx;
      } else {
         if (IsPeakPoint(idx, radius, prices)) return idx;
      }
   }
   return -1;
}
//+------------------------------------------------------------------+
//| Verify Valley Point (Local Minimum)                              |
//+------------------------------------------------------------------+
bool IsValleyPoint(const int centerBar, const int wingspan, const double &low[]) {
   double centerValue = low[centerBar];
  
   for (int offset = 1; offset <= wingspan; offset++) {
      if (centerValue >= low[centerBar - offset] || centerValue >= low[centerBar + offset]) {
         return false;
      }
   }
   return true;
}
//+------------------------------------------------------------------+
//| Verify Peak Point (Local Maximum)                                |
//+------------------------------------------------------------------+
bool IsPeakPoint(const int centerBar, const int wingspan, const double &high[]) {
   double centerValue = high[centerBar];
  
   for (int offset = 1; offset <= wingspan; offset++) {
      if (centerValue <= high[centerBar - offset] || centerValue <= high[centerBar + offset]) {
         return false;
      }
   }
   return true;
}
//+------------------------------------------------------------------+
//| Render Trendline On Chart                                        |
//+------------------------------------------------------------------+
void RenderTrendline(const string objectTag, const CPriceLevel &point1,
                     const CPriceLevel &point2, const color lineColor,
                     const ENUM_LINE_STYLE style = STYLE_SOLID,
                     const int width = 2) {
   string objectName = IdentifierPrefix + "-" + objectTag;
  
   // Remove Existing Object
   if (ObjectFind(0, objectName) >= 0) {
      ObjectDelete(0, objectName);
   }
  
   // Create Trendline Object
   if (!ObjectCreate(0, objectName, OBJ_TREND, 0,
                     point1.Timestamp(), point1.Price(),
                     point2.Timestamp(), point2.Price())) {
      Print("Warning: Failed to create ", objectName, " - Error: ", GetLastError());
      return;
   }
  
   // Configure Visual Properties
   ObjectSetInteger(0, objectName, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, objectName, OBJPROP_STYLE, style);
   ObjectSetInteger(0, objectName, OBJPROP_RAY_LEFT, true);
   ObjectSetInteger(0, objectName, OBJPROP_RAY_RIGHT, ProjectForward);
   ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, objectName, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, objectName, OBJPROP_BACK, true);
  
   // Attach Information Tooltip
   ObjectSetString(0, objectName, OBJPROP_TOOLTIP,
                   StringFormat("%s | Price: %.5f | Time: %s",
                   objectTag, point1.Price(), TimeToString(point1.Timestamp())));
}
//+------------------------------------------------------------------+