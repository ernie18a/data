//+------------------------------------------------------------------+
//|                               News-Gap-Spread-Risk-Dashboard.mq5 |
//|                                      Developed by stratcorealpha |
//|                     https://www.mql5.com/de/users/stratcorealpha |
//|                                      https://stratcorealpha.com/ |
//+------------------------------------------------------------------+
#property copyright "Developed by stratcorealpha | https://www.mql5.com/de/users/stratcorealpha | https://stratcorealpha.com/"
#property link      "https://stratcorealpha.com/"
#property version   "2.20"
#property indicator_chart_window
#property indicator_plots 0

//--- Includes
#include <Arrays\ArrayObj.mqh>

//--- Enums
enum ENUM_DISPLAY_MODE
  {
   MODE_SMART_AUTO,        // Auto: Pips for Forex, Price Diff for Crypto/Gold/Indices
   MODE_PRICE_DIFFERENCE,  // Always Price Difference (Ask - Bid) e.g. "12.00" for BTC
   MODE_PERCENTAGE,        // Spread % of Price (Universal Risk Metric)
   MODE_PIPS_CLASSIC,      // Force Classic Pips
   MODE_RAW_POINTS         // Force Raw Points
  };

enum ENUM_THRESHOLD_MODE
  {
   THRESH_MODE_RELATIVE,   // Relative (Multiplier of Average) - Recommended
   THRESH_MODE_ABSOLUTE    // Absolute Value (Fixed Limit)
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Calculation Logic ==="
input ENUM_DISPLAY_MODE InpDisplayMode = MODE_SMART_AUTO;    // Display Unit
input ENUM_THRESHOLD_MODE InpThreshMode= THRESH_MODE_RELATIVE;// Warning Logic
input double   InpRiskMultiplier       = 1.5;        // Relative Warning (e.g. 1.5x Avg)
input double   InpFixedThreshold       = 5.0;        // Absolute Limit (in Display Unit)

input group "=== Symbol-Specific Thresholds ==="
input bool     InpUseSymbolThresholds  = true;       // Use Symbol-Specific Thresholds (overrides Fixed)
input string   InpSymbolThresholds     = "EURUSD:3.0,GBPUSD:3.5,USDJPY:2.5,USDCAD:3.2,XAUUSD:30.0,US30:8.0"; // Format: SYMBOL:THRESHOLD,...

input group "=== Spread History ==="
input int      InpWindowSeconds        = 300;        // Rolling Window (Seconds)
input int      InpSampleIntervalMs     = 500;        // Update Speed (ms) - Faster for Crypto
input int      InpMinSampleIntervalMs  = 250;        // Min Time Between Samples (ms) - Prevents array explosion

input group "=== UI Settings ==="
input ENUM_BASE_CORNER InpCorner       = CORNER_LEFT_UPPER; // Panel Corner
input int      InpOffsetX              = 20;         // Offset X
input int      InpOffsetY              = 50;         // Offset Y
input int      InpPanelWidth           = 250;        // Panel Width
input int      InpPanelHeight          = 145;        // Panel Height (compact 5-line display)
input int      InpFontSize             = 9;          // Font Size
input string   InpFontName             = "Consolas"; // Font Name
input color    InpColorBgNormal        = clrDarkSlateGray; // Background Normal
input color    InpColorBgWarning       = clrFireBrick;     // Background Warning
input color    InpColorText            = clrWhite;         // Text Color
input color    InpColorLabel           = clrSilver;        // Label Color

input group "=== Alerts ==="
input bool     InpEnableAlerts         = true;       // Enable Alerts
input bool     InpAlertPopup           = false;      // Popup Alert
input bool     InpAlertSound           = false;      // Sound Alert
input string   InpSoundFile            = "alert.wav";// Sound File
input bool     InpAlertPush            = false;      // Push Notification
input int      InpAlertCooldown        = 60;         // Alert Cooldown (Seconds)

input group "=== Debug ==="
input bool     InpDebugMode            = false;      // Enable Debug Logging (not for live)

//+------------------------------------------------------------------+
//| Structures & Globals                                             |
//+------------------------------------------------------------------+
struct SpreadSample
  {
   datetime          time;
   double            value; // Stored in Display Unit
  };

SpreadSample g_samples[];      // 5-minute window samples
double       g_conversionFactor = 1.0;
string       g_unitLabel = "";
int          g_displayDigits = 2; // Smart precision
datetime     g_lastAlertTime = 0;
double       g_lastLiveValue = 0.0; // Last calculated live spread value for reuse
string       g_prefix = "NewsSpreadRisk_";

// Symbol thresholds cache
double       g_symbolThreshold = 5.0; // Calculated threshold for current symbol

// UI Object Names
string ObjNamePanel, ObjNameHeader, ObjNameSymbolTf, ObjNameCurrent,
       ObjNameMin, ObjNameMax, ObjNameAvg, ObjNameStatus;

//+------------------------------------------------------------------+
//| Custom Indicator Initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ConfigureCalculation();
   ParseSymbolThresholds();
   InitializeUI();

// High frequency timer for smoother crypto updates
   EventSetMillisecondTimer(InpSampleIntervalMs);

   UpdateStorage(); // First tick immediate
   UpdateDashboard();

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Configuration Logic                                              |
//+------------------------------------------------------------------+
void ConfigureCalculation()
  {
   ENUM_SYMBOL_CALC_MODE calc_mode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   bool isForex = (calc_mode == SYMBOL_CALC_MODE_FOREX || calc_mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE);

// Default settings
   g_conversionFactor = 1.0;
   g_unitLabel = "val";
   g_displayDigits = digits;

   ENUM_DISPLAY_MODE effectiveMode = InpDisplayMode;

// Handle Auto Mode
   if(effectiveMode == MODE_SMART_AUTO)
     {
      if(isForex)
         effectiveMode = MODE_PIPS_CLASSIC;
      else
         effectiveMode = MODE_PRICE_DIFFERENCE;
     }

// Apply Specific Logic
   switch(effectiveMode)
     {
      case MODE_PIPS_CLASSIC:
         // 1 Pip = 10 Points for 3/5 digit brokers
         if(digits == 3 || digits == 5)
            g_conversionFactor = point * 10;
         else
            g_conversionFactor = point;

         g_unitLabel = "pips";
         g_displayDigits = 1; // Pips usually displayed with 1 decimal (e.g. 1.2 pips)
         break;

      case MODE_PRICE_DIFFERENCE:
        {
         // Real Price Difference (Ask - Bid)
         // Factor is 1.0 relative to Price.
         // But Spread is returned in Points usually, or we calc Ask-Bid directly.
         // We will calc Ask-Bid directly in Logic, so factor is 1.0.
         g_conversionFactor = 1.0;

         // Unit detection
         string profitCurrency = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
         if(profitCurrency != "")
            g_unitLabel = profitCurrency;
         else
            g_unitLabel = "$"; // Fallback

         g_displayDigits = digits;
         // Cap digits for crypto/indices to avoid messy displays (e.g. Bitcoin 12.0000000)
         if(g_displayDigits > 2 && StringFind(SymbolInfoString(_Symbol, SYMBOL_PATH), "Crypto") >= 0)
            g_displayDigits = 2;
         break;
        }

      case MODE_PERCENTAGE:
         // % of Price. Factor handled in calc.
         g_unitLabel = "%";
         g_displayDigits = 3; // e.g. 0.015%
         break;

      case MODE_RAW_POINTS:
         g_conversionFactor = point; // Actually, if we use Ask-Bid, we divide by Point to get Points
         // Wait, standard is: ValueInPoints = (Ask-Bid) / Point
         g_unitLabel = "pts";
         g_displayDigits = 0;
         break;
     }
  }

//+------------------------------------------------------------------+
//| Parse Symbol-Specific Thresholds                                 |
//+------------------------------------------------------------------+
void ParseSymbolThresholds()
  {
   g_symbolThreshold = InpFixedThreshold; // Default fallback

   if(!InpUseSymbolThresholds)
      return;

   string thresholds = InpSymbolThresholds;
   string symbol = _Symbol;

// Remove any suffix/prefix from current symbol (e.g., "EURUSD.a" -> "EURUSD")
   int dotPos = StringFind(symbol, ".");
   if(dotPos > 0)
      symbol = StringSubstr(symbol, 0, dotPos);

// Parse CSV format: SYMBOL:THRESHOLD,SYMBOL2:THRESHOLD2
   string entries[];
   int entryCount = StringSplit(thresholds, ',', entries);

   for(int i = 0; i < entryCount; i++)
     {
      string parts[];
      int partCount = StringSplit(entries[i], ':', parts);

      if(partCount == 2)
        {
         string entrySymbol = parts[0];
         double entryThreshold = StringToDouble(parts[1]);

         if(entrySymbol == symbol && entryThreshold > 0)
           {
            g_symbolThreshold = entryThreshold;
            Print("Using symbol-specific threshold for ", symbol, ": ", entryThreshold);
            return;
           }
        }
     }

// If no specific threshold found for this symbol, set reasonable defaults based on symbol type
   SetDefaultThresholdForSymbol(symbol);
  }

//+------------------------------------------------------------------+
//| Set Default Threshold Based on Symbol Type                       |
//+------------------------------------------------------------------+
void SetDefaultThresholdForSymbol(string symbol)
  {
   string upper = symbol;
   StringToUpper(upper);

   if(StringFind(upper, "EURUSD") >= 0)
      g_symbolThreshold = 3.0;
   else
      if(StringFind(upper, "GBPUSD") >= 0)
         g_symbolThreshold = 3.5;
      else
         if(StringFind(upper, "USDJPY") >= 0)
            g_symbolThreshold = 2.5;
         else
            if(StringFind(upper, "USDCAD") >= 0)
               g_symbolThreshold = 3.2;
            else
               if(StringFind(upper, "AUDUSD") >= 0)
                  g_symbolThreshold = 3.0;
               else
                  if(StringFind(upper, "NZDUSD") >= 0)
                     g_symbolThreshold = 3.2;
                  else
                     if(StringFind(upper, "USDCHF") >= 0)
                        g_symbolThreshold = 3.5;
                     else
                        if(StringFind(upper, "XAUUSD") >= 0)
                           g_symbolThreshold = 30.0;   // Gold in USD
                        else
                           if(StringFind(upper, "US30") >= 0)
                              g_symbolThreshold = 8.0;      // Dow Jones
                           else
                              if(StringFind(upper, "US100") >= 0)
                                 g_symbolThreshold = 6.0;     // Nasdaq
                              else
                                 if(StringFind(upper, "DE40") >= 0)
                                    g_symbolThreshold = 7.0;      // DAX
                                 else
                                    if(StringFind(upper, "BTC") >= 0)
                                       g_symbolThreshold = 50.0;      // Bitcoin in USD
                                    else
                                       if(StringFind(upper, "ETH") >= 0)
                                          g_symbolThreshold = 25.0;      // Ethereum in USD
                                       else
                                          g_symbolThreshold = 3.0; // Generic Forex default

   Print("Using auto-detected threshold for ", symbol, ": ", g_symbolThreshold);
  }

//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteUI();
  }

//+------------------------------------------------------------------+
//| OnCalculate (Standard)                                           |
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
// Update logic is handled by the timer to prevent race conditions
// This ensures single-threaded access to shared data structures
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateStorage();
   UpdateDashboard();
  }

//+------------------------------------------------------------------+
//| Core Logic: Measure & Store                                      |
//+------------------------------------------------------------------+
void UpdateStorage()
  {
// Get fresh prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(ask <= 0 || bid <= 0)
     {
      Print("Invalid prices - Ask: ", ask, " Bid: ", bid);
      return;
     }

   double rawDiff = ask - bid;
   double finalValue = 0.0;

// Optional Debug Logging
   static datetime lastDebugTime = 0;
   if(InpDebugMode && TimeCurrent() - lastDebugTime >= 10)
     {
      lastDebugTime = TimeCurrent();
      Print("DEBUG: Ask=", ask, " Bid=", bid, " Spread=", rawDiff);
     }

   ENUM_DISPLAY_MODE effectiveMode = InpDisplayMode;
   if(effectiveMode == MODE_SMART_AUTO)
     {
      ENUM_SYMBOL_CALC_MODE calc_mode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE);
      bool isForex = (calc_mode == SYMBOL_CALC_MODE_FOREX || calc_mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE);
      effectiveMode = isForex ? MODE_PIPS_CLASSIC : MODE_PRICE_DIFFERENCE;
     }

// --- Calculation Switch ---
   switch(effectiveMode)
     {
      case MODE_PIPS_CLASSIC:
         // (Ask - Bid) / PipSize
         finalValue = rawDiff / g_conversionFactor;
         break;

      case MODE_PRICE_DIFFERENCE:
         // Pure Price Difference (e.g. $12.50)
         finalValue = rawDiff;
         break;

      case MODE_PERCENTAGE:
         // (Spread / Bid) * 100
         if(bid > 0)
            finalValue = (rawDiff / bid) * 100.0;
         break;

      case MODE_RAW_POINTS:
        {
         // (Ask - Bid) / Point
         double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         if(pt > 0)
            finalValue = rawDiff / pt;
         break;
        }
     }

// --- Store Sample (5m window) ---
   int size = ArraySize(g_samples);

// NEW: Milliseconds-based check instead of time-based
// This allows multiple samples per second for crypto while preventing array explosion
   bool shouldStore = true;
   if(size > 0)
     {
      // Calculate time difference in milliseconds
      long timeDiff = (long)((TimeCurrent() - g_samples[size-1].time) * 1000.0);
      if(timeDiff < InpMinSampleIntervalMs)
         shouldStore = false; // Skip if too soon since last sample
     }

   if(shouldStore)
     {
      // Add new sample
      if(size >= 3600) // Safety cap
        {
         ArrayRemove(g_samples, 0, 1);
         size--;
        }
      ArrayResize(g_samples, size + 1);
      g_samples[size].time = TimeCurrent();
      g_samples[size].value = finalValue;
     }

// Store live value for reuse in dashboard update
   g_lastLiveValue = finalValue;

// --- Prune Old (5m window) ---
   datetime cutoff = TimeCurrent() - InpWindowSeconds;
   int removeCount = 0;
   for(int i=0; i<ArraySize(g_samples); i++)
     {
      if(g_samples[i].time < cutoff)
         removeCount++;
      else
         break;
     }
   if(removeCount > 0)
      ArrayRemove(g_samples, 0, removeCount);


  }

//+------------------------------------------------------------------+
//| Logic: Update UI                                                 |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   int count = ArraySize(g_samples);

// --- 1. Retrieve Live Value from Storage ---
// Use the value cached from UpdateStorage() to avoid redundant calculations
   double liveVal = g_lastLiveValue;  // Cached from the most recent UpdateStorage() call

// --- 2. Calculate History Stats (Min/Max/Avg) for 5m ---
   double minVal = DBL_MAX;
   double maxVal = -DBL_MAX;
   double sumVal = 0.0;

   if(count > 0)
     {
      for(int i=0; i<count; i++)
        {
         double v = g_samples[i].value;
         if(v < minVal)
            minVal = v;
         if(v > maxVal)
            maxVal = v;
         sumVal += v;
        }
     }
   else
     {
      minVal = liveVal;
      maxVal = liveVal;
      sumVal = liveVal;
      count = 1;
     }

   double avgVal = sumVal / count;
   double ratio = (avgVal > 0.0000001) ? liveVal / avgVal : 1.0;

// Optional Debug Logging
   static datetime lastDebugTime2 = 0;
   if(InpDebugMode && TimeCurrent() - lastDebugTime2 >= 10)
     {
      lastDebugTime2 = TimeCurrent();
      Print("DEBUG: liveVal=", StringFormat("%0.2f", liveVal),
            " min=", StringFormat("%0.2f", minVal),
            " max=", StringFormat("%0.2f", maxVal),
            " avg=", StringFormat("%0.2f", avgVal),
            " samples=", count);
     }


// --- 4. Warning Check (Using Live Value) ---
   bool isWarning = false;
   string reason = "";

   if(InpThreshMode == THRESH_MODE_RELATIVE)
     {
      if(avgVal > 0 && liveVal >= (avgVal * InpRiskMultiplier))
        {
         isWarning = true;
         reason = StringFormat("Spike %.1fx", ratio);
        }
     }
   else // THRESH_MODE_ABSOLUTE
     {
      double threshold = InpUseSymbolThresholds ? g_symbolThreshold : InpFixedThreshold;
      if(liveVal >= threshold)
        {
         isWarning = true;
         reason = "Limit Hit";
        }
     }

// --- 5. Update Colors ---
   color bg = isWarning ? InpColorBgWarning : InpColorBgNormal;
   ObjectSetInteger(0, ObjNamePanel, OBJPROP_BGCOLOR, bg);

// --- 6. Update Text ---
   string fmt = "%." + IntegerToString(g_displayDigits) + "f %s";
   string symbolOnly = _Symbol;
   int dotPos = StringFind(symbolOnly, ".");
   if(dotPos > 0)
      symbolOnly = StringSubstr(symbolOnly, 0, dotPos);

   SetText(ObjNameHeader, "NEWS SPREAD RISK", InpOffsetX+10, InpOffsetY+5);
   SetText(ObjNameSymbolTf, symbolOnly + " | " + EnumToString((ENUM_TIMEFRAMES)_Period), InpOffsetX+10, InpOffsetY+23);
   SetText(ObjNameCurrent, StringFormat("Current:   " + fmt, liveVal, g_unitLabel), InpOffsetX+10, InpOffsetY+45);
   SetText(ObjNameMin,     StringFormat("Min (5m):  " + fmt, minVal, g_unitLabel), InpOffsetX+10, InpOffsetY+65);
   SetText(ObjNameMax,     StringFormat("Max (5m):  " + fmt, maxVal, g_unitLabel), InpOffsetX+10, InpOffsetY+85);
   SetText(ObjNameAvg,     StringFormat("Avg (5m):  " + fmt, avgVal, g_unitLabel), InpOffsetX+10, InpOffsetY+105);

   string status = isWarning ? "RISK: " + reason : "Status: Stable";
   SetText(ObjNameStatus, status, InpOffsetX+10, InpOffsetY+125);

// --- 7. Alerts ---
   if(isWarning && InpEnableAlerts && (TimeCurrent() - g_lastAlertTime > InpAlertCooldown))
     {
      string msg = StringFormat("SPREAD SPIKE %s: %.2f %s (%s)", _Symbol, liveVal, g_unitLabel, reason);
      if(InpAlertPopup)
         Alert(msg);
      if(InpAlertPush)
         SendNotification(msg);
      if(InpAlertSound)
         PlaySound(InpSoundFile);
      g_lastAlertTime = TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
//| UI Helpers                                                       |
//+------------------------------------------------------------------+
void InitializeUI()
  {
   string id = IntegerToString(ChartID());
   ObjNamePanel   = g_prefix + "Panel_" + id;
   ObjNameHeader  = g_prefix + "Header_" + id;
   ObjNameSymbolTf = g_prefix + "SymbolTf_" + id;
   ObjNameCurrent = g_prefix + "Current_" + id;
   ObjNameMin     = g_prefix + "Min_" + id;
   ObjNameMax     = g_prefix + "Max_" + id;
   ObjNameAvg     = g_prefix + "Avg_" + id;
   ObjNameStatus  = g_prefix + "Status_" + id;

   if(ObjectCreate(0, ObjNamePanel, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_XDISTANCE, InpOffsetX);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_YDISTANCE, InpOffsetY);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_XSIZE, InpPanelWidth);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_YSIZE, InpPanelHeight);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_BGCOLOR, InpColorBgNormal);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_BACK, false);
      ObjectSetInteger(0, ObjNamePanel, OBJPROP_HIDDEN, true);
     }

   CreateLabel(ObjNameHeader, "NEWS SPREAD RISK", InpOffsetX+10, InpOffsetY+5, clrWhite, true);
   CreateLabel(ObjNameSymbolTf, "Initializing...", InpOffsetX+10, InpOffsetY+23, clrSilver);
   CreateLabel(ObjNameCurrent, "Init...", InpOffsetX+10, InpOffsetY+45, InpColorText);
   CreateLabel(ObjNameMin,     "Init...", InpOffsetX+10, InpOffsetY+65, InpColorLabel);
   CreateLabel(ObjNameMax,     "Init...", InpOffsetX+10, InpOffsetY+85, InpColorLabel);
   CreateLabel(ObjNameAvg,     "Init...", InpOffsetX+10, InpOffsetY+105, InpColorLabel);
   CreateLabel(ObjNameStatus,  "Init...", InpOffsetX+10, InpOffsetY+125, clrWhite);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color col, bool bold=false)
  {
   if(ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Black" : InpFontName);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string name, string text, int x, int y)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteUI()
  {
   ObjectDelete(0, ObjNamePanel);
   ObjectDelete(0, ObjNameHeader);
   ObjectDelete(0, ObjNameSymbolTf);
   ObjectDelete(0, ObjNameCurrent);
   ObjectDelete(0, ObjNameMin);
   ObjectDelete(0, ObjNameMax);
   ObjectDelete(0, ObjNameAvg);
   ObjectDelete(0, ObjNameStatus);
  }
//+------------------------------------------------------------------+
