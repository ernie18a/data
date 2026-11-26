//+------------------------------------------------------------------+
//|                             Wick-Rejection-Scanner-Dashboard.mq5 |
//|                Professional MT5 Wick Rejection Scanner Dashboard |
//|            Completely redesigned UI with proper visual hierarchy |
//+------------------------------------------------------------------+
#property copyright "Developed by stratcorealpha | https://www.mql5.com/de/users/stratcorealpha | https://stratcorealpha.com/"
#property link      "https://stratcorealpha.com/"
#property version   "3.00"
#property description "Scan multiple symbols/timeframes for wick-based rejection candles"
#property description "Features: Professional UI, Signal age, Strength score, Trend filter"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Input Parameters - Detection Settings (Optimized for Realistic Trading) |
//+------------------------------------------------------------------+
input group "=== Detection Settings ==="
input int    WickThresholdPct = 40;           // Wick Threshold (% of candle range) - standard rejection level
input int    MinRangePoints = 35;             // Minimum Range in Points (~3.5 pips for 5-digit brokers) - balanced filtering
input int    MinBodyPct = 10;                 // Minimum Body Percentage - ensures meaningful candles
input int    MaxOppositeWickPct = 30;         // Max Opposite Wick Percentage - ensures clean rejection
input bool   UseATRFilter = true;             // Use ATR Filter - ensures volatility-based signals
input int    ATRPeriod = 14;                  // ATR Period
input double MinATRMultiplier = 1.0;          // Min ATR Multiplier - candle must be >= 1x ATR
input bool   UseTrendContext = true;          // Use Trend Context Filter - improves signal quality
input int    TrendContextBars = 20;           // Trend Context Lookback Bars
input int    TrendContextThreshold = 15;      // Trend Context Threshold
input bool   DebugMode = false;               // Debug mode - shows details in Experts tab (default: off)

//+------------------------------------------------------------------+
//| Input Parameters - Scanner Settings                              |
//+------------------------------------------------------------------+
input group "=== Scanner Settings ==="
input bool   UseMarketWatchSymbols = true;    // Use Market Watch Symbols
input int    MaxMarketWatchSymbols = 20;      // Max Market Watch Symbols to Scan (default: Top 20)
input string CustomSymbols = "";              // Custom Symbol List (comma-separated)
input ENUM_TIMEFRAMES ScanTimeframe = PERIOD_H1; // Primary Scan Timeframe
input bool   UseCurrentChartTimeframe = true;     // Use Current Chart Timeframe instead of ScanTimeframe
input bool   ScanM15 = false;                 // Also Scan M15
input bool   ScanH4 = false;                  // Also Scan H4
input int    BarsToCheck = 50;                // Check Last N Bars (balanced for realistic signals)
input bool   CheckClosedCandleOnly = true;    // Check Closed Candles Only
input int    RefreshSeconds = 10;             // Dashboard Refresh Interval (increased for performance)
input int    ShowOnlyLastNSignals = 0;        // Show Only Last N Signals (0 = all)

//+------------------------------------------------------------------+
//| Input Parameters - UI Settings                                   |
//+------------------------------------------------------------------+
input group "=== UI Settings ==="
input bool   ShowDashboard = true;            // Show Dashboard
input bool   ShowOnChartMarkers = true;       // Show Markers on Chart
input int    MaxMarkersOnChart = 50;          // Max Markers on Chart
input bool   ShowLabels = true;               // Show Wick Percentage Labels
input color  UpperRejectionColor = clrRed;    // Upper Rejection Color
input color  LowerRejectionColor = clrGreen;  // Lower Rejection Color
input int    DashboardCorner = CORNER_LEFT_UPPER; // Dashboard Corner [1=TopRight|2=TopLeft|3=BottomLeft|4=BottomRight]
input int    DashboardXOffset = 10;           // Dashboard X Offset (pixels from corner)
input int    DashboardYOffset = 60;           // Dashboard Y Offset (pixels from corner)
input int    RowHeight = 18;                  // Dashboard Row Height
input int    FontSize = 10;                   // Dashboard Font Size (increased for better readability)
input bool   ShowOnlyActiveSignals = false;   // Show Only Active Signals (false = show all with timestamps)
input bool   EnableClickToSwitchChart = true; // Enable Click to Switch Chart
input int    DashboardSortMode = 0;           // Sort Mode [0=Most Recent|1=Highest Wick%|2=Highest Strength]

//+------------------------------------------------------------------+
//| Input Parameters - Alert Settings                                |
//+------------------------------------------------------------------+
input group "=== Alert Settings ==="
input bool   EnablePopupAlert = false;        // Enable Popup Alerts (default: off - less annoying)
input bool   EnablePushNotification = false;  // Enable Push Notifications
input bool   EnableEmail = false;             // Enable Email Alerts
input int    AlertCooldownMinutes = 30;       // Alert Cooldown (minutes)

//+------------------------------------------------------------------+
//| Global Variables and Structures                                  |
//+------------------------------------------------------------------+
struct SignalData
  {
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   datetime          signalTime;
   bool              isUpperRejection;
   double            wickPercentage;
   double            strengthScore;
   double            rangeInPoints;
   int               barsAgo;
   double            contextScore;
  };

struct AlertRecord
  {
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   datetime          lastAlertTime;
  };

//--- Global Arrays and Buffers
SignalData signals[];
AlertRecord alertHistory[];
string symbolList[];
uint dashboardTimer;
datetime lastBarTime = 0;

//--- Dummy buffer for indicator
double dummyBuffer[];

//+------------------------------------------------------------------+
//| Helper: Custom string trim function                              |
//+------------------------------------------------------------------+
string StringTrimCustom(string str)
  {
   int len = StringLen(str);
   if(len == 0)
      return "";

   int start = 0;
   int end = len - 1;

// Trim left (spaces and tabs)
   while(start <= end && ((uchar)StringGetCharacter(str, start) == ' ' || (uchar)StringGetCharacter(str, start) == '\t'))
      start++;

// Trim right (spaces and tabs)
   while(end >= start && ((uchar)StringGetCharacter(str, end) == ' ' || (uchar)StringGetCharacter(str, end) == '\t'))
      end--;

   if(start > end)
      return "";
   return StringSubstr(str, start, end - start + 1);
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize dummy buffer
   SetIndexBuffer(0, dummyBuffer);

//--- Initialize symbol list
   if(!InitializeSymbolList())
     {
      // Silent fail - no alert on initialization error
      return(INIT_FAILED);
     }

//--- Initialize dashboard timer
   dashboardTimer = GetTickCount();

//--- Set timer for regular updates
   EventSetTimer(1);

//--- Clean up any existing objects on first load
   CleanupAllWRSObjects();

//--- Print initialization info (disabled to avoid alert on init)
// Print("Wick Rejection Scanner v3.0 initialized. Symbols: ", ArraySize(symbolList));

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Clean up all dashboard objects AND chart markers
   CleanupAllWRSObjects();
   CleanupWRSMarkerObjects();

//--- Kill timer
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| OnCalculate - required for indicator                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer function - Main update loop                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Check if refresh interval has passed
   uint currentTick = GetTickCount();
   if(currentTick - dashboardTimer < (uint)RefreshSeconds * 1000)
      return;

//--- Update timer
   dashboardTimer = currentTick;

//--- Scan all symbols and update dashboard
   if(ShowDashboard)
     {
      ScanAllSymbols();
      RenderProfessionalDashboard();
     }

//--- Update chart markers for current symbol
   if(ShowOnChartMarkers)
     {
      UpdateChartMarkers();
     }
  }

//+------------------------------------------------------------------+
//| Initialize symbol list from MarketWatch or custom list          |
//+------------------------------------------------------------------+
bool InitializeSymbolList()
  {
   if(UseMarketWatchSymbols)
     {
      int symbolsTotal = SymbolsTotal(false);
      if(symbolsTotal == 0)
         return(false);

      // Limit to MaxMarketWatchSymbols (default: 20) for better performance
      int limitCount = MathMin(symbolsTotal, MaxMarketWatchSymbols);
      ArrayResize(symbolList, limitCount);

      for(int i = 0; i < limitCount; i++)
        {
         symbolList[i] = SymbolName(i, false);
        }
     }
   else
     {
      //--- Parse custom symbol list
      if(StringLen(CustomSymbols) == 0)
         return(false);

      string customList[];
      StringSplit(CustomSymbols, StringGetCharacter(",", 0), customList);

      int validCount = 0;
      for(int i = 0; i < ArraySize(customList); i++)
        {
         customList[i] = StringTrimCustom(customList[i]);
         if(SymbolExists(customList[i]))
           {
            validCount++;
           }
        }

      ArrayResize(symbolList, validCount);
      validCount = 0;

      for(int i = 0; i < ArraySize(customList); i++)
        {
         customList[i] = StringTrimCustom(customList[i]);
         if(SymbolExists(customList[i]))
           {
            symbolList[validCount++] = customList[i];
           }
        }
     }

   return(ArraySize(symbolList) > 0);
  }

//+------------------------------------------------------------------+
//| Check if symbol exists                                           |
//+------------------------------------------------------------------+
bool SymbolExists(string symbol)
  {
   long value = 0;
   return(SymbolInfoInteger(symbol, SYMBOL_EXIST, value));
  }

//+------------------------------------------------------------------+
//| Normalize points based on broker digits                          |
//+------------------------------------------------------------------+
double NormalizePoints(const string symbol)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

//--- Adjust for 5-digit brokers (standardize to 4-digit)
   if(digits == 5 || digits == 3)
      return(point * 10.0);

   return point;
  }

//+------------------------------------------------------------------+
//| Scan all symbols for wick rejections                             |
//+------------------------------------------------------------------+
void ScanAllSymbols()
  {
   ArrayResize(signals, 0);

//--- Get timeframes to scan
   ENUM_TIMEFRAMES timeframes[];
   int tfCount = 0;

   ArrayResize(timeframes, 3);

// Use current chart timeframe if enabled, otherwise use configured ScanTimeframe
   if(UseCurrentChartTimeframe)
      timeframes[tfCount++] = Period();  // Use current chart timeframe
   else
      timeframes[tfCount++] = ScanTimeframe;

   if(ScanM15)
      timeframes[tfCount++] = PERIOD_M15;
   if(ScanH4)
      timeframes[tfCount++] = PERIOD_H4;

   ArrayResize(timeframes, tfCount);

//--- Scan each symbol and timeframe
   for(int s = 0; s < ArraySize(symbolList); s++)
     {
      string symbol = symbolList[s];

      for(int t = 0; t < tfCount; t++)
        {
         ENUM_TIMEFRAMES timeframe = timeframes[t];

         if(!SymbolExists(symbol))
            continue;

         SignalData signal = ScanSymbolTimeframe(symbol, timeframe);

         if(signal.signalTime > 0)
           {
            int newSize = ArraySize(signals);
            ArrayResize(signals, newSize + 1);
            signals[newSize] = signal;
           }
        }
     }

//--- Sort signals based on user preference
   SortSignals();

//--- Limit signals displayed
   if(ShowOnlyLastNSignals > 0 && ArraySize(signals) > ShowOnlyLastNSignals)
     {
      ArrayResize(signals, ShowOnlyLastNSignals);
     }
  }

//+------------------------------------------------------------------+
//| Scan a specific symbol and timeframe for signals                 |
//+------------------------------------------------------------------+
SignalData ScanSymbolTimeframe(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   SignalData result;
   ZeroMemory(result);

   result.symbol = symbol;
   result.timeframe = timeframe;

//--- Calculate ATR if filter is enabled
   double atrValue = 0.0;
   int currentBars = iBars(symbol, timeframe);

   if(currentBars < 10)
      return(result);

   if(UseATRFilter)
     {
      int atrHandle = iATR(symbol, timeframe, ATRPeriod);
      if(atrHandle != INVALID_HANDLE)
        {
         double atrValues[];
         int copied = CopyBuffer(atrHandle, 0, 1, 1, atrValues);
         if(copied > 0 && ArraySize(atrValues) > 0)
           {
            atrValue = atrValues[0];
           }
         IndicatorRelease(atrHandle);
        }
     }

//--- Scan recent bars
   int barsToCheck = MathMin(BarsToCheck, currentBars - 2);

   for(int i = 1; i <= barsToCheck; i++)
     {
      double high = iHigh(symbol, timeframe, i);
      double low = iLow(symbol, timeframe, i);
      double open = iOpen(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i);

      SignalData signal = CalculateRejectionSignal(symbol, timeframe, high, low, open, close, i, atrValue);

      if(signal.signalTime > 0)
        {
         return signal; // Return the most recent signal
        }
     }

   return result;
  }

//+------------------------------------------------------------------+
//| Calculate Trend Context Score                                    |
//+------------------------------------------------------------------+
double CalculateTrendContext(string symbol, ENUM_TIMEFRAMES timeframe, double high, double low, double close, bool isUpper)
  {
   if(!UseTrendContext)
      return 0;

//--- Get recent high/low range
   double periodHigh = high;
   double periodLow = low;

   for(int i = 1; i < TrendContextBars; i++)
     {
      double barHigh = iHigh(symbol, timeframe, i);
      double barLow = iLow(symbol, timeframe, i);

      if(barHigh > periodHigh)
         periodHigh = barHigh;
      if(barLow < periodLow)
         periodLow = barLow;
     }

   double range = periodHigh - periodLow;
   if(range == 0)
      return 0;

//--- Calculate percentile position
   double percentile = (close - periodLow) / range * 100.0;

//--- For upper rejection: should be near high (high percentile)
//--- For lower rejection: should be near low (low percentile)
   if(isUpper)
     {
      return MathMax(0, 100 - percentile);
     }
   else
     {
      return MathMax(0, percentile);
     }
  }

//+------------------------------------------------------------------+
//| Calculate Rejection Signal                                       |
//+------------------------------------------------------------------+
SignalData CalculateRejectionSignal(string symbol, ENUM_TIMEFRAMES timeframe,
                                    double high, double low, double open, double close,
                                    int barsAgo, double atrValue)
  {
   SignalData result;
   ZeroMemory(result);

   result.symbol = symbol;
   result.timeframe = timeframe;
   result.barsAgo = barsAgo;

//--- Calculate candle properties
   double range = high - low;
   double body = MathAbs(close - open);
   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;

//--- Normalize points for broker digits
   double minRange = MinRangePoints * NormalizePoints(symbol);

//--- Check minimum range
   if(range <= minRange)
     {
      if(DebugMode)
         Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - Range too small: ", range, " (min: ", minRange, ")");
      return result;
     }

//--- Calculate percentages
   double upperWickPct = (range > 0) ? (upperWick / range * 100.0) : 0;
   double lowerWickPct = (range > 0) ? (lowerWick / range * 100.0) : 0;
   double bodyPct = (range > 0) ? (body / range * 100.0) : 0;

//--- Check ATR filter if enabled
   if(UseATRFilter && atrValue > 0)
     {
      if(range < atrValue * MinATRMultiplier)
        {
         if(DebugMode)
            Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - ATR filter: range ", range, " < ", atrValue * MinATRMultiplier);
         return result;
        }
     }

//--- Check upper rejection
   if(upperWickPct >= WickThresholdPct)
     {
      //--- Check body filter
      if(bodyPct < MinBodyPct)
        {
         if(DebugMode)
            Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - UPPER Wick ", upperWickPct, "% but body too small: ", bodyPct, "% (min: ", MinBodyPct, "%)");
         return result;
        }

      //--- Check opposite wick cap
      if(lowerWickPct > MaxOppositeWickPct)
        {
         if(DebugMode)
            Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - UPPER Wick ", upperWickPct, "% but opposite wick too large: ", lowerWickPct, "% (max: ", MaxOppositeWickPct, "%)");
         return result;
        }

      result.isUpperRejection = true;
      result.wickPercentage = upperWickPct;
      result.signalTime = iTime(symbol, timeframe, barsAgo);
      result.strengthScore = CalculateStrengthScore(upperWickPct, lowerWickPct, bodyPct, range, true);
      result.contextScore = CalculateTrendContext(symbol, timeframe, high, low, close, true);

      //--- Apply trend context penalty
      if(UseTrendContext && result.contextScore > TrendContextThreshold)
         result.strengthScore *= (1 - result.contextScore / 100.0 * 0.3);
     }
//--- Check lower rejection
   else
      if(lowerWickPct >= WickThresholdPct)
        {
         //--- Check body filter
         if(bodyPct < MinBodyPct)
           {
            if(DebugMode)
               Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - LOWER Wick ", lowerWickPct, "% but body too small: ", bodyPct, "% (min: ", MinBodyPct, "%)");
            return result;
           }

         //--- Check opposite wick cap
         if(upperWickPct > MaxOppositeWickPct)
           {
            if(DebugMode)
               Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - LOWER Wick ", lowerWickPct, "% but opposite wick too large: ", upperWickPct, "% (max: ", MaxOppositeWickPct, "%)");
            return result;
           }

         result.isUpperRejection = false;
         result.wickPercentage = lowerWickPct;
         result.signalTime = iTime(symbol, timeframe, barsAgo);
         result.strengthScore = CalculateStrengthScore(lowerWickPct, upperWickPct, bodyPct, range, false);
         result.contextScore = CalculateTrendContext(symbol, timeframe, high, low, close, false);

         //--- Apply trend context penalty
         if(UseTrendContext && result.contextScore > TrendContextThreshold)
            result.strengthScore *= (1 - result.contextScore / 100.0 * 0.3);
        }

   result.rangeInPoints = range / NormalizePoints(symbol);

// Debug output for successful signals
   if(result.signalTime > 0 && DebugMode)
     {
      Print("DEBUG FOUND: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo, " - ",
            result.isUpperRejection ? "UPPER" : "LOWER", " REJECTION! Wick: ",
            result.wickPercentage, "% Body: ", bodyPct, "% Strength: ", result.strengthScore);
     }
// Debug output for candles without sufficient wick
   else
      if(result.signalTime == 0 && DebugMode)
        {
         Print("DEBUG SKIP: ", symbol, " ", TimeframeToString(timeframe), " Bar ", barsAgo,
               " - Wick too small: Upper ", upperWickPct, "% Lower ", lowerWickPct,
               "% (threshold: ", WickThresholdPct, "%)");
        }

   return result;
  }

//+------------------------------------------------------------------+
//| Calculate Signal Strength Score                                  |
//+------------------------------------------------------------------+
double CalculateStrengthScore(double wickPct, double oppositeWickPct, double bodyPct, double range, bool isUpper)
  {
   double score = wickPct * 0.6;

//--- Penalty for large opposite wick
   score -= oppositeWickPct * 0.5;

//--- Bonus for reasonable body size
   if(bodyPct >= MinBodyPct)
     {
      if(bodyPct <= 30)
         score += 15;
      else
         if(bodyPct <= 50)
            score += 10;
     }

//--- Bonus for large range (volatility)
   if(range > 0)
     {
      double avgRange = 0.0;
      int atrHandle = iATR(_Symbol, _Period, 14);
      if(atrHandle != INVALID_HANDLE)
        {
         double atrValues[];
         int copied = CopyBuffer(atrHandle, 0, 1, 1, atrValues);
         if(copied > 0 && ArraySize(atrValues) > 0)
            avgRange = atrValues[0];
         IndicatorRelease(atrHandle);
        }

      if(avgRange > 0 && range > avgRange)
         score += 10;
     }

//--- Cap at 100
   if(score > 100)
      score = 100;
   if(score < 0)
      score = 0;

   return score;
  }

//+------------------------------------------------------------------+
//| Sort signals based on user preference                            |
//+------------------------------------------------------------------+
void SortSignals()
  {
   int signalCount = ArraySize(signals);
   if(signalCount <= 1)
      return;

//--- Bubble sort (simple but effective for small arrays)
   for(int i = 0; i < signalCount - 1; i++)
     {
      for(int j = 0; j < signalCount - i - 1; j++)
        {
         bool swap = false;

         switch(DashboardSortMode)
           {
            case 0: // Sort by most recent signal time
               swap = signals[j].signalTime < signals[j + 1].signalTime;
               break;
            case 1: // Sort by highest wick percentage
               swap = signals[j].wickPercentage < signals[j + 1].wickPercentage;
               break;
            case 2: // Sort by highest strength score
               swap = signals[j].strengthScore < signals[j + 1].strengthScore;
               break;
           }

         if(swap)
           {
            SignalData temp = signals[j];
            signals[j] = signals[j + 1];
            signals[j + 1] = temp;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Helper: Calculate dynamic panel width based on chart size       |
//+------------------------------------------------------------------+
int CalculateDynamicPanelWidth()
  {
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int maxWidth = MathMin(450, chartWidth * 80 / 100);  // Max 80% of chart width
   return MathMax(350, maxWidth);  // Minimum 350px
  }

//+------------------------------------------------------------------+
//| Helper: Get chart-specific object prefix                         |
//+------------------------------------------------------------------+
string GetObjPrefix()
  {
   long chartID = ChartID();
   return StringFormat("WRS_%d_", chartID);
  }

//+------------------------------------------------------------------+
//| Render Professional Dashboard with proper visual hierarchy       |
//+------------------------------------------------------------------+
void RenderProfessionalDashboard()
  {
//--- Aggressively clean ALL WRS objects before rendering
   CleanupAllWRSObjects();

   if(!ShowDashboard)
      return;

//--- Dashboard dimensions (professionally calculated with dynamic width)
   int PANEL_WIDTH = CalculateDynamicPanelWidth();
   const int HEADER_HEIGHT = 25; // Header section
   const int COL_HEADER_HEIGHT = 18; // Column headers
   const int MAX_VISIBLE_ROWS = 12; // Limit for readability
   const int ROW_HEIGHT = 18;

   int visibleSignalCount = MathMin(ArraySize(signals), MAX_VISIBLE_ROWS);
   int panelHeight = HEADER_HEIGHT + COL_HEADER_HEIGHT + (visibleSignalCount * ROW_HEIGHT) + 25;

//--- Colors - Modern Dark Theme (Orange)
   color panelBgColor = clrBlack;             // Pure black
   color headerBgColor = (color)0x0D0D0D;     // Very dark gray
   color headerTextColor = clrWhite;
   color borderColor = clrOrange;             // Orange accent!
   color colHeaderColor = clrLightGray;
   color rowBgColor1 = (color)0x1A1A1A;       // Dark gray (even rows)
   color rowBgColor2 = (color)0x252525;       // Slightly lighter (odd rows)
   color textColor = clrWhite;                // Main text color
   color textSecondary = (color)0xCCCCCC;     // Secondary text (light gray)

//--- 1. MAIN PANEL BACKGROUND (solid, professional)
   string mainBgName = "WRS_MainPanel";
   if(ObjectCreate(0, mainBgName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, mainBgName, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, mainBgName, OBJPROP_XDISTANCE, DashboardXOffset);
      ObjectSetInteger(0, mainBgName, OBJPROP_YDISTANCE, DashboardYOffset);
      ObjectSetInteger(0, mainBgName, OBJPROP_XSIZE, PANEL_WIDTH);
      ObjectSetInteger(0, mainBgName, OBJPROP_YSIZE, panelHeight);
      ObjectSetInteger(0, mainBgName, OBJPROP_BGCOLOR, panelBgColor);
      ObjectSetInteger(0, mainBgName, OBJPROP_COLOR, borderColor);
      ObjectSetInteger(0, mainBgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, mainBgName, OBJPROP_BACK, false);  // false = solid foreground (undurchsichtig)
      ObjectSetInteger(0, mainBgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, mainBgName, OBJPROP_ZORDER, 10);  // Increased above chart markers
     }

//--- 2. HEADER SECTION (black background, white text)
   string headerBgName = "WRS_HeaderBG";
   if(ObjectCreate(0, headerBgName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, headerBgName, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, headerBgName, OBJPROP_XDISTANCE, DashboardXOffset);
      ObjectSetInteger(0, headerBgName, OBJPROP_YDISTANCE, DashboardYOffset);
      ObjectSetInteger(0, headerBgName, OBJPROP_XSIZE, PANEL_WIDTH);
      ObjectSetInteger(0, headerBgName, OBJPROP_YSIZE, HEADER_HEIGHT);
      ObjectSetInteger(0, headerBgName, OBJPROP_BGCOLOR, headerBgColor);
      ObjectSetInteger(0, headerBgName, OBJPROP_BORDER_COLOR, borderColor);
      ObjectSetInteger(0, headerBgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, headerBgName, OBJPROP_BACK, false);  // false = solid foreground (undurchsichtig)
      ObjectSetInteger(0, headerBgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, headerBgName, OBJPROP_ZORDER, 11);  // Increased above chart markers
     }

//--- Header Title
   string sortModeText = DashboardSortMode == 0 ? "RECENT" : DashboardSortMode == 1 ? "WICK%" : "STRENGTH";
   string headerTitle = StringFormat("WICK SCANNER - %d SYMBOLS - SORT: %s", ArraySize(symbolList), sortModeText);
   string headerTitleName = "WRS_Header_Title";

   if(ObjectCreate(0, headerTitleName, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, headerTitleName, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, headerTitleName, OBJPROP_XDISTANCE, DashboardXOffset + 10);
      ObjectSetInteger(0, headerTitleName, OBJPROP_YDISTANCE, DashboardYOffset + 4);
      ObjectSetString(0, headerTitleName, OBJPROP_TEXT, headerTitle);
      ObjectSetInteger(0, headerTitleName, OBJPROP_COLOR, headerTextColor);
      ObjectSetInteger(0, headerTitleName, OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(0, headerTitleName, OBJPROP_FONT, "Calibri Bold");
      ObjectSetInteger(0, headerTitleName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, headerTitleName, OBJPROP_ZORDER, 2);
     }

//--- Update Time
   string updateTime = TimeToString(TimeCurrent(), TIME_MINUTES);
   string updateTimeTitle = "WRS_UpdateTime";

   if(ObjectCreate(0, updateTimeTitle, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_XDISTANCE, DashboardXOffset + PANEL_WIDTH - 50);
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_YDISTANCE, DashboardYOffset + 4);
      ObjectSetString(0, updateTimeTitle, OBJPROP_TEXT, updateTime);
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_COLOR, clrLightGray);
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(0, updateTimeTitle, OBJPROP_FONT, "Calibri");
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, updateTimeTitle, OBJPROP_ZORDER, 2);
     }

//--- 3. COLUMN HEADERS (under header, above data)
   int colHeaderY = DashboardYOffset + HEADER_HEIGHT;

// Column separator line
   string colSeparator = "WRS_ColSeparator";
   if(ObjectCreate(0, colSeparator, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, colSeparator, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, colSeparator, OBJPROP_XDISTANCE, DashboardXOffset);
      ObjectSetInteger(0, colSeparator, OBJPROP_YDISTANCE, colHeaderY);
      ObjectSetInteger(0, colSeparator, OBJPROP_XSIZE, PANEL_WIDTH);
      ObjectSetInteger(0, colSeparator, OBJPROP_YSIZE, 1);
      ObjectSetInteger(0, colSeparator, OBJPROP_BGCOLOR, borderColor);
      ObjectSetInteger(0, colSeparator, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, colSeparator, OBJPROP_ZORDER, 1);
     }

// Column headers text
   CreateDashboardLabel("WRS_Col_Symbol", "SYMBOL", DashboardXOffset + 8, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);
   CreateDashboardLabel("WRS_Col_TF", "TF", DashboardXOffset + 70, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);
   CreateDashboardLabel("WRS_Col_Signal", "SIGNAL", DashboardXOffset + 102, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);
   CreateDashboardLabel("WRS_Col_Wick", "WICK%", DashboardXOffset + 158, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);
   CreateDashboardLabel("WRS_Col_Strength", "STR", DashboardXOffset + 210, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);
   CreateDashboardLabel("WRS_Col_Age", "AGE", DashboardXOffset + 250, colHeaderY + 1, colHeaderColor, "Calibri Bold", FontSize);

//--- 4. DATA ROWS (alternating background, clean data display)
   for(int i = 0; i < visibleSignalCount; i++)
     {
      int rowY = colHeaderY + COL_HEADER_HEIGHT + (i * ROW_HEIGHT);

      // Row background (alternating colors)
      color bgColor = (i % 2 == 0) ? rowBgColor1 : rowBgColor2;
      string rowBgName = StringFormat("WRS_RowBg_%d", i);

      if(ObjectCreate(0, rowBgName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        {
         ObjectSetInteger(0, rowBgName, OBJPROP_CORNER, DashboardCorner);
         ObjectSetInteger(0, rowBgName, OBJPROP_XDISTANCE, DashboardXOffset);
         ObjectSetInteger(0, rowBgName, OBJPROP_YDISTANCE, rowY);
         ObjectSetInteger(0, rowBgName, OBJPROP_XSIZE, PANEL_WIDTH);
         ObjectSetInteger(0, rowBgName, OBJPROP_YSIZE, ROW_HEIGHT);
         ObjectSetInteger(0, rowBgName, OBJPROP_BGCOLOR, bgColor);
         ObjectSetInteger(0, rowBgName, OBJPROP_BACK, false);  // false = solid foreground (undurchsichtig)
         ObjectSetInteger(0, rowBgName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, rowBgName, OBJPROP_ZORDER, 10);  // Increased above chart markers
        }

      // Create row separator line
      if(i < visibleSignalCount - 1)
        {
         string rowSeparator = StringFormat("WRS_RowSeparator_%d", i);
         if(ObjectCreate(0, rowSeparator, OBJ_RECTANGLE_LABEL, 0, 0, 0))
           {
            ObjectSetInteger(0, rowSeparator, OBJPROP_CORNER, DashboardCorner);
            ObjectSetInteger(0, rowSeparator, OBJPROP_XDISTANCE, DashboardXOffset);
            ObjectSetInteger(0, rowSeparator, OBJPROP_YDISTANCE, rowY + ROW_HEIGHT);
            ObjectSetInteger(0, rowSeparator, OBJPROP_XSIZE, PANEL_WIDTH);
            ObjectSetInteger(0, rowSeparator, OBJPROP_YSIZE, 1);
            ObjectSetInteger(0, rowSeparator, OBJPROP_BGCOLOR, clrDimGray);
            ObjectSetInteger(0, rowSeparator, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, rowSeparator, OBJPROP_ZORDER, 2);
           }
        }

      //--- DATA CELLS (professional alignment)
      SignalData signal = signals[i];

      // Symbol
      CreateDashboardLabel(StringFormat("WRS_Data_Symbol_%d", i), signal.symbol, DashboardXOffset + 8, rowY + 2, clrWhite, "Calibri", FontSize);

      // Timeframe
      string tf = TimeframeToString(signal.timeframe);
      CreateDashboardLabel(StringFormat("WRS_Data_TF_%d", i), tf, DashboardXOffset + 70, rowY + 2, clrLightGray, "Calibri", FontSize);

      // Signal Type
      string signalText = signal.isUpperRejection ? "UPPER" : "LOWER";
      color signalColor = signal.isUpperRejection ? UpperRejectionColor : LowerRejectionColor;
      CreateDashboardLabel(StringFormat("WRS_Data_Signal_%d", i), signalText, DashboardXOffset + 102, rowY + 2, signalColor, "Calibri Bold", FontSize);

      // Wick %
      string wickText = StringFormat("%.1f%%", signal.wickPercentage);
      CreateDashboardLabel(StringFormat("WRS_Data_Wick_%d", i), wickText, DashboardXOffset + 158, rowY + 2, clrLightGray, "Calibri", FontSize);

      // Strength (colored by value)
      string strengthText = StringFormat("%.0f", signal.strengthScore);
      color strengthColor = clrYellow;
      if(signal.strengthScore >= 70)
         strengthColor = clrLimeGreen;
      else
         if(signal.strengthScore >= 40)
            strengthColor = clrOrange;
         else
            strengthColor = clrRed;
      CreateDashboardLabel(StringFormat("WRS_Data_Strength_%d", i), strengthText, DashboardXOffset + 210, rowY + 2, strengthColor, "Calibri Bold", FontSize);

      // Age (compact format)
      string ageText = (signal.barsAgo <= 1) ? StringFormat("%d bar", signal.barsAgo) :
                       StringFormat("%d bars", signal.barsAgo);
      if(signal.barsAgo <= 1)
         ageText = TimeToString(signal.signalTime, TIME_MINUTES);
      CreateDashboardLabel(StringFormat("WRS_Data_Age_%d", i), ageText, DashboardXOffset + 250, rowY + 2, clrLightBlue, "Calibri", FontSize);

      //--- Clickable button overlay (invisible but interactive)
      if(EnableClickToSwitchChart)
        {
         string clickBtnName = StringFormat("WRS_ClickBtn_%d", i);
         if(ObjectCreate(0, clickBtnName, OBJ_BUTTON, 0, 0, 0))
           {
            ObjectSetInteger(0, clickBtnName, OBJPROP_CORNER, DashboardCorner);
            ObjectSetInteger(0, clickBtnName, OBJPROP_XDISTANCE, DashboardXOffset);
            ObjectSetInteger(0, clickBtnName, OBJPROP_YDISTANCE, rowY);
            ObjectSetInteger(0, clickBtnName, OBJPROP_XSIZE, PANEL_WIDTH);
            ObjectSetInteger(0, clickBtnName, OBJPROP_YSIZE, ROW_HEIGHT);
            ObjectSetInteger(0, clickBtnName, OBJPROP_BGCOLOR, clrNONE);
            ObjectSetInteger(0, clickBtnName, OBJPROP_COLOR, clrNONE);
            ObjectSetInteger(0, clickBtnName, OBJPROP_BORDER_COLOR, clrNONE);
            ObjectSetString(0, clickBtnName, OBJPROP_TEXT, "");  // Empty for invisible button
            ObjectSetInteger(0, clickBtnName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, clickBtnName, OBJPROP_ZORDER, 50);  // Higher than all background elements

            // Store symbol and timeframe in tooltip as string (not integer)
            string descriptor = StringFormat("%s,%s", signal.symbol, TimeframeToString(signal.timeframe));
            ObjectSetString(0, clickBtnName, OBJPROP_TOOLTIP, descriptor);
           }
        }
     }

//--- 5. FOOTER SECTION (if no signals)
   if(visibleSignalCount == 0)
     {
      int footerY = colHeaderY + COL_HEADER_HEIGHT + 5;
      string noSignalMsg = "NO ACTIVE SIGNALS";

      if(ShowOnlyActiveSignals)
         noSignalMsg = "NO ACTIVE SIGNALS";
      else
         noSignalMsg = "NO SIGNALS FOUND";

      CreateDashboardLabel("WRS_NoSignal", noSignalMsg, DashboardXOffset + (PANEL_WIDTH/2) - 60, footerY, clrGray, "Calibri", FontSize + 1);
     }
  }

//+------------------------------------------------------------------+
//| Helper: Create a dashboard label with professional defaults      |
//+------------------------------------------------------------------+
void CreateDashboardLabel(string name, string text, int x, int y, color col, string font, int size)
  {
   if(ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_CORNER, DashboardCorner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
      ObjectSetString(0, name, OBJPROP_FONT, font);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 2);
     }
  }

//+------------------------------------------------------------------+
//| Update chart markers for current symbol                          |
//+------------------------------------------------------------------+
void UpdateChartMarkers()
  {
//--- Clean existing markers
   CleanupWRSMarkerObjects();

   string currentSymbol = Symbol();
   ENUM_TIMEFRAMES currentTf = Period();
   int currentBars = Bars(currentSymbol, currentTf);

   if(currentBars < 10)
      return;

//--- Calculate ATR if enabled
   double atrValue = 0.0;
   if(UseATRFilter)
     {
      int atrHandle = iATR(currentSymbol, currentTf, ATRPeriod);
      if(atrHandle != INVALID_HANDLE)
        {
         double atrValues[];
         int copied = CopyBuffer(atrHandle, 0, 1, 1, atrValues);
         if(copied > 0 && ArraySize(atrValues) > 0)
            atrValue = atrValues[0];
         IndicatorRelease(atrHandle);
        }
     }

   int markersCreated = 0;

//--- Scan recent bars
   int barsToCheck = MathMin(BarsToCheck, currentBars - 2);

   for(int i = 1; i <= barsToCheck && markersCreated < MaxMarkersOnChart; i++)
     {
      double high = iHigh(currentSymbol, currentTf, i);
      double low = iLow(currentSymbol, currentTf, i);
      double open = iOpen(currentSymbol, currentTf, i);
      double close = iClose(currentSymbol, currentTf, i);

      SignalData signal = CalculateRejectionSignal(currentSymbol, currentTf, high, low, open, close, i, atrValue);

      if(signal.signalTime > 0)
        {
         CreateChartMarker(signal, i);
         markersCreated++;

         //--- Check for alerts
         CheckAlert(signal);
        }
     }
  }

//+------------------------------------------------------------------+
//| Create chart marker                                              |
//+------------------------------------------------------------------+
void CreateChartMarker(const SignalData &signal, int shift)
  {
   datetime barTime = (datetime)signal.signalTime;
   string barTimeStr = TimeToString(barTime, TIME_DATE|TIME_MINUTES);
   barTimeStr = StringReplaceTime(barTimeStr);

//--- Clean arrow name
   string cleanSymbol = StringCleanForObject(signal.symbol);
   string cleanTime = StringCleanForObject(barTimeStr);
   string arrowName = StringFormat("WRS_Marker_Arrow_%s_%s_%s", cleanSymbol, TimeframeToString(signal.timeframe), cleanTime);

//--- Get bar coordinates
   double arrPrice = signal.isUpperRejection ? iHigh(signal.symbol, signal.timeframe, shift) + 15 * NormalizePoints(signal.symbol) :
                     iLow(signal.symbol, signal.timeframe, shift) - 15 * NormalizePoints(signal.symbol);

//--- Create arrow (direction matches rejection: upper=down arrow, lower=up arrow)
   if(ObjectCreate(0, arrowName, OBJ_ARROW, 0, barTime, arrPrice))
     {
      if(signal.isUpperRejection)
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 234);  // Down arrow (↓) for upper rejection
      else
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233);  // Up arrow (↑) for lower rejection

      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, signal.isUpperRejection ? UpperRejectionColor : LowerRejectionColor);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
     }

//--- Create label if enabled
   if(ShowLabels)
     {
      string labelName = StringFormat("WRS_Marker_Label_%s_%s_%s", cleanSymbol, TimeframeToString(signal.timeframe), cleanTime);
      double labelPrice = signal.isUpperRejection ? iHigh(signal.symbol, signal.timeframe, shift) + 40 * NormalizePoints(signal.symbol) :
                          iLow(signal.symbol, signal.timeframe, shift) - 40 * NormalizePoints(signal.symbol);

      if(ObjectCreate(0, labelName, OBJ_TEXT, 0, barTime, labelPrice))
        {
         ObjectSetString(0, labelName, OBJPROP_TEXT, StringFormat("%.1f%%", signal.wickPercentage));
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, signal.isUpperRejection ? UpperRejectionColor : LowerRejectionColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
        }
     }
  }

//+------------------------------------------------------------------+
//| Helper: Clean string for object names                            |
//+------------------------------------------------------------------+
string StringCleanForObject(string str)
  {
   string result = str;
   result = StringReplaceChar(result, (uchar)':', (uchar)'_');
   result = StringReplaceChar(result, (uchar)'.', (uchar)'_');
   result = StringReplaceChar(result, (uchar)' ', (uchar)'_');
   result = StringReplaceChar(result, (uchar)'-', (uchar)'_');
   return result;
  }

//+------------------------------------------------------------------+
//| Helper: Replace characters in string                             |
//+------------------------------------------------------------------+
string StringReplaceChar(string str, uchar oldChar, uchar newChar)
  {
   string result = "";
   int len = StringLen(str);

   for(int i = 0; i < len; i++)
     {
      uchar currentChar = (uchar)StringGetCharacter(str, i);
      if(currentChar == oldChar)
         result += CharToString(newChar);
      else
         result += CharToString(currentChar);
     }

   return result;
  }

//+------------------------------------------------------------------+
//| Helper: Replace time string characters                           |
//+------------------------------------------------------------------+
string StringReplaceTime(string str)
  {
   string result = str;
   result = StringReplaceChar(result, (uchar)':', (uchar)'_');
   result = StringReplaceChar(result, (uchar)'.', (uchar)'_');
   result = StringReplaceChar(result, (uchar)' ', (uchar)'_');
   return result;
  }

//+------------------------------------------------------------------+
//| Convert timeframe to string                                      |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_CURRENT:
         return "CUR";
      case PERIOD_M1:
         return "M1";
      case PERIOD_M2:
         return "M2";
      case PERIOD_M3:
         return "M3";
      case PERIOD_M4:
         return "M4";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M6:
         return "M6";
      case PERIOD_M10:
         return "M10";
      case PERIOD_M12:
         return "M12";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M20:
         return "M20";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H2:
         return "H2";
      case PERIOD_H3:
         return "H3";
      case PERIOD_H4:
         return "H4";
      case PERIOD_H6:
         return "H6";
      case PERIOD_H8:
         return "H8";
      case PERIOD_H12:
         return "H12";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN";
      default:
         return "TF";
     }
  }

//+------------------------------------------------------------------+
//| Convert string to timeframe                                       |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTimeframe(string tf)
  {
   if(tf == "M1")
      return PERIOD_M1;
   if(tf == "M2")
      return PERIOD_M2;
   if(tf == "M3")
      return PERIOD_M3;
   if(tf == "M4")
      return PERIOD_M4;
   if(tf == "M5")
      return PERIOD_M5;
   if(tf == "M6")
      return PERIOD_M6;
   if(tf == "M10")
      return PERIOD_M10;
   if(tf == "M12")
      return PERIOD_M12;
   if(tf == "M15")
      return PERIOD_M15;
   if(tf == "M20")
      return PERIOD_M20;
   if(tf == "M30")
      return PERIOD_M30;
   if(tf == "H1")
      return PERIOD_H1;
   if(tf == "H2")
      return PERIOD_H2;
   if(tf == "H3")
      return PERIOD_H3;
   if(tf == "H4")
      return PERIOD_H4;
   if(tf == "H6")
      return PERIOD_H6;
   if(tf == "H8")
      return PERIOD_H8;
   if(tf == "H12")
      return PERIOD_H12;
   if(tf == "D1")
      return PERIOD_D1;
   if(tf == "W1")
      return PERIOD_W1;
   if(tf == "MN")
      return PERIOD_MN1;
   return PERIOD_CURRENT;
  }

//+------------------------------------------------------------------+
//| Check and send alerts                                           |
//+------------------------------------------------------------------+
void CheckAlert(const SignalData &signal)
  {
   if(!EnablePopupAlert && !EnablePushNotification && !EnableEmail)
      return;

//--- Check cooldown
   datetime now = TimeCurrent();

   for(int i = 0; i < ArraySize(alertHistory); i++)
     {
      if(alertHistory[i].symbol == signal.symbol &&
         alertHistory[i].timeframe == signal.timeframe)
        {
         if(now - alertHistory[i].lastAlertTime < AlertCooldownMinutes * 60)
            return;
        }
     }

//--- Send alerts
   string message = StringFormat("Wick Scanner: %s %s %s | Wick=%.1f%% | Strength=%.0f | %s",
                                 signal.symbol,
                                 TimeframeToString(signal.timeframe),
                                 signal.isUpperRejection ? "UPPER" : "LOWER",
                                 signal.wickPercentage,
                                 signal.strengthScore,
                                 TimeToString(signal.signalTime, TIME_MINUTES));

   if(EnablePopupAlert)
      Alert(message);
   if(EnablePushNotification)
      SendNotification(message);
   if(EnableEmail)
      SendMail("Wick Scanner Alert", message);

//--- Update alert history
   int historyIndex = -1;
   for(int i = 0; i < ArraySize(alertHistory); i++)
     {
      if(alertHistory[i].symbol == signal.symbol &&
         alertHistory[i].timeframe == signal.timeframe)
        {
         historyIndex = i;
         break;
        }
     }

   if(historyIndex == -1)
     {
      historyIndex = ArraySize(alertHistory);
      ArrayResize(alertHistory, historyIndex + 1);
     }

   alertHistory[historyIndex].symbol = signal.symbol;
   alertHistory[historyIndex].timeframe = signal.timeframe;
   alertHistory[historyIndex].lastAlertTime = now;
  }

//+------------------------------------------------------------------+
//| Chart event handler - Handle clicks on dashboard                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   if(!EnableClickToSwitchChart)
      return;

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      string objName = sparam;
      if(StringFind(objName, "WRS_ClickBtn_", 0) == 0)
        {
         // Read descriptor from tooltip (not text property)
         string descriptor = ObjectGetString(0, objName, OBJPROP_TOOLTIP);
         if(StringFind(descriptor, ",", 0) > 0)
           {
            string parts[];
            StringSplit(descriptor, StringGetCharacter(",", 0), parts);

            if(ArraySize(parts) == 2)
              {
               string symbol = parts[0];
               string tfString = parts[1];
               ENUM_TIMEFRAMES tf = StringToTimeframe(tfString);

               if(SymbolExists(symbol))
                 {
                  ChartSetSymbolPeriod(0, symbol, tf);
                 }
              }
           }

         // Reset button state
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
        }
     }
  }

//+------------------------------------------------------------------+
//| Cleanup Functions - Delete all WRS dashboard objects (not markers)|
//+------------------------------------------------------------------+
void CleanupAllWRSObjects()
  {
// Clean only dashboard objects, not chart markers (WRS_Marker_*)
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string objName = ObjectName(0, i, 0, -1);
      if(StringFind(objName, "WRS_", 0) == 0 && StringFind(objName, "WRS_Marker_") != 0)
        {
         ObjectDelete(0, objName);
        }
     }
  }

//+------------------------------------------------------------------+
//| Cleanup Functions - Delete all WRS marker objects                |
//+------------------------------------------------------------------+
void CleanupWRSMarkerObjects()
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string objName = ObjectName(0, i, 0, -1);
      if(StringFind(objName, "WRS_Marker_", 0) == 0)
        {
         ObjectDelete(0, objName);
        }
     }
  }

//+------------------------------------------------------------------+
