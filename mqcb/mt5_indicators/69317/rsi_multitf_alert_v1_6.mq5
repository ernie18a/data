//+------------------------------------------------------------------+
//|                                       RSI_MultiTF_Alert_v1.6.mq5 |
//|                                     Copyright 2026, Jaume Sancho |
//|                                      https://github.com/jimmer89 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Jaume Sancho"
#property link      "https://github.com/jimmer89"
#property version   "1.60"
#property description "Multi-timeframe RSI scanner with visual dashboard and alerts"
#property description "v1.6 - Production ready: alert retry, verbose control, all constants"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Constants (FIX: extracted from magic numbers)                     |
//+------------------------------------------------------------------+
const double RSI_CHANGE_THRESHOLD = 0.1;       // Minimum RSI change to trigger visual update
const int    ALIGNMENT_THRESHOLD = 3;          // Minimum TFs aligned for warning
const int    DASHBOARD_PADDING = 15;           // Dashboard padding in pixels
const int    MIN_VALID_TF_PERCENT = 50;        // Minimum % of TFs with valid data
const int    ITIME_WARNING_COOLDOWN = 60;      // Seconds between iTime warnings

//--- v1.5: Additional UI constants
const int    DASHBOARD_MARGIN = 5;             // Margin around dashboard elements
const int    TITLE_FONT_BOOST = 2;             // Extra font size for title
const int    LINE_SPACING_EXTRA = 5;           // Extra spacing after title/before align
const int    MIN_CHART_MARGIN = 100;           // Minimum margin from chart edge for validation

//--- v1.6: Additional constants for full coverage
const int    LINE_HEIGHT_PADDING = 8;          // Padding added to font size for line height
const int    DEFAULT_DASH_X = 20;              // Default X position if validation fails
const int    DEFAULT_DASH_Y = 50;              // Default Y position if validation fails
const int    ALERT_MAX_RETRIES = 2;            // Max retries for failed alerts
const int    ALERT_RETRY_DELAY_MS = 100;       // Delay between retries in milliseconds

//+------------------------------------------------------------------+
//| Input parameters                                                  |
//+------------------------------------------------------------------+
input group "=== RSI Settings ==="
input int      RSI_Period = 14;              // RSI Period (1-500)
input double   Overbought_Level = 70.0;      // Overbought Level (50-100)
input double   Oversold_Level = 30.0;        // Oversold Level (0-50)

input group "=== Timeframe Selection ==="
input bool     Show_M1 = true;               // Show M1
input bool     Show_M5 = true;               // Show M5
input bool     Show_M15 = true;              // Show M15
input bool     Show_M30 = true;              // Show M30
input bool     Show_H1 = true;               // Show H1
input bool     Show_H4 = true;               // Show H4
input bool     Show_D1 = true;               // Show D1

input group "=== Alert Settings ==="
input bool     Enable_Push_Alerts = true;    // Enable Push Notifications
input bool     Enable_Email_Alerts = false;  // Enable Email Alerts
input bool     Enable_Sound_Alerts = true;   // Enable Sound Alerts
input string   Alert_Sound = "alert2.wav";   // Alert Sound File

input group "=== Display Settings ==="
input int      Dashboard_X = 20;             // Dashboard X Position
input int      Dashboard_Y = 50;             // Dashboard Y Position
input int      Dashboard_Width = 200;        // Dashboard Width (pixels)
input color    Color_Overbought = clrRed;    // Overbought Color
input color    Color_Oversold = clrDodgerBlue; // Oversold Color
input color    Color_Neutral = clrGray;      // Neutral Color
input color    Color_Background = C'20,20,20'; // Dashboard Background
input int      Font_Size = 10;               // Font Size (6-24)
input int      Update_Seconds = 1;           // Update Interval (1-60 seconds)

input group "=== Advanced Settings ==="
input bool     Verbose_Logging = false;      // Enable verbose debug logging
input bool     Alert_Retry_Enabled = true;   // Retry failed alerts

//+------------------------------------------------------------------+
//| Global variables                                                  |
//+------------------------------------------------------------------+
//--- Dynamic arrays for selected timeframes
ENUM_TIMEFRAMES g_timeframes[];
string g_timeframeNames[];
int g_rsiHandles[];
datetime g_lastAlertTime[];
double g_lastRsiValues[];
double g_currentRsiValues[];
datetime g_lastItimeWarning[];  // FIX: throttle iTime warnings per TF

//--- Cached count (FIX: avoid repeated ArraySize calls)
int g_tfCount = 0;

//--- Precalculated object names (fix hot path string allocation)
string g_tfLabelNames[];
string g_rsiLabelNames[];
string g_statusLabelNames[];

//--- Dashboard objects
const string OBJ_PREFIX = "RSI_MTF_";
string g_bgName;
string g_titleName;
string g_alignName;

//--- Validated input values
int g_rsiPeriod;
double g_obLevel;
double g_osLevel;
int g_fontSize;
int g_updateSeconds;
int g_dashWidth;
int g_dashX;  // FIX: validated dashboard position
int g_dashY;

//--- Proportional positions (FIX: calculated based on font size)
int g_rsiLabelOffset;      // X offset for RSI value labels
int g_statusLabelOffset;   // X offset for status labels

//--- State flags (FIX: no more static vars in functions)
bool g_dataReady = false;
bool g_loadingShown = false;       // FIX: was static in UpdateLoadingState()
int g_lastOBCount = -1;            // FIX: was static in UpdateAlignmentIndicator()
int g_lastOSCount = -1;            // FIX: was static in UpdateAlignmentIndicator()

//+------------------------------------------------------------------+
//| Release all RSI handles safely                                    |
//+------------------------------------------------------------------+
void ReleaseAllHandles()
{
   for(int i = 0; i < ArraySize(g_rsiHandles); i++)
   {
      if(g_rsiHandles[i] != INVALID_HANDLE)
      {
         IndicatorRelease(g_rsiHandles[i]);
         g_rsiHandles[i] = INVALID_HANDLE;
      }
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- FIX: Release any existing handles FIRST (prevents memory leak on re-init)
   ReleaseAllHandles();
   
   //--- Reset all state flags (FIX: ensures clean state on re-init)
   g_dataReady = false;
   g_loadingShown = false;
   g_lastOBCount = -1;
   g_lastOSCount = -1;
   g_tfCount = 0;
   
   //--- Validate inputs first
   if(!ValidateInputs())
      return(INIT_PARAMETERS_INCORRECT);
   
   //--- Calculate proportional UI positions (FIX: adapt to font size)
   CalculateUIPositions();
   
   //--- Build dynamic timeframe arrays based on user selection
   if(!BuildTimeframeArrays())
   {
      Print("Error: No timeframes selected! Enable at least one timeframe.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   g_tfCount = ArraySize(g_timeframes);  // FIX: cache count
   
   //--- Resize all arrays with reserve (avoid O(n²) resize)
   ArrayResize(g_rsiHandles, g_tfCount, g_tfCount);
   ArrayResize(g_lastAlertTime, g_tfCount, g_tfCount);
   ArrayResize(g_lastRsiValues, g_tfCount, g_tfCount);
   ArrayResize(g_currentRsiValues, g_tfCount, g_tfCount);
   ArrayResize(g_lastItimeWarning, g_tfCount, g_tfCount);  // FIX: new array
   ArrayResize(g_tfLabelNames, g_tfCount, g_tfCount);
   ArrayResize(g_rsiLabelNames, g_tfCount, g_tfCount);
   ArrayResize(g_statusLabelNames, g_tfCount, g_tfCount);
   
   //--- Initialize arrays
   ArrayInitialize(g_lastAlertTime, 0);
   ArrayInitialize(g_lastRsiValues, -1.0);
   ArrayInitialize(g_currentRsiValues, -1.0);
   ArrayInitialize(g_lastItimeWarning, 0);
   
   //--- Initialize handles to INVALID before creating (for cleanup on failure)
   ArrayInitialize(g_rsiHandles, INVALID_HANDLE);
   
   //--- Precalculate object names (fix hot path string creation)
   g_bgName = OBJ_PREFIX + "BG";
   g_titleName = OBJ_PREFIX + "Title";
   g_alignName = OBJ_PREFIX + "Align";
   
   for(int i = 0; i < g_tfCount; i++)
   {
      string idx = IntegerToString(i);
      g_tfLabelNames[i] = OBJ_PREFIX + "TF_" + idx;
      g_rsiLabelNames[i] = OBJ_PREFIX + "RSI_" + idx;
      g_statusLabelNames[i] = OBJ_PREFIX + "Status_" + idx;
   }
   
   //--- Create RSI handles for selected timeframes
   for(int i = 0; i < g_tfCount; i++)
   {
      ResetLastError();
      g_rsiHandles[i] = iRSI(_Symbol, g_timeframes[i], g_rsiPeriod, PRICE_CLOSE);
      
      if(g_rsiHandles[i] == INVALID_HANDLE)
      {
         int err = GetLastError();
         Print("Error creating RSI handle for ", g_timeframeNames[i], 
               " - Error code: ", err, " (", ErrorDescription(err), ")");
         
         //--- FIX: Release handles created so far before failing
         for(int j = 0; j < i; j++)
         {
            if(g_rsiHandles[j] != INVALID_HANDLE)
            {
               IndicatorRelease(g_rsiHandles[j]);
               g_rsiHandles[j] = INVALID_HANDLE;
            }
         }
         return(INIT_FAILED);
      }
   }
   
   //--- Create dashboard
   CreateDashboard();
   
   //--- Set indicator short name
   string shortName = StringFormat("RSI MTF(%d) [%d TFs]", g_rsiPeriod, g_tfCount);
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
   
   //--- Set timer for updates (only use timer, not OnCalculate)
   EventSetTimer(g_updateSeconds);
   
   Print("RSI_MultiTF_Alert v1.6 initialized - Monitoring ", g_tfCount, " timeframes on ", _Symbol);
   if(Verbose_Logging) Print("Debug: Verbose logging enabled");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Calculate UI positions proportional to font size                  |
//+------------------------------------------------------------------+
void CalculateUIPositions()
{
   //--- Base multipliers for font size 10 (reference)
   //--- At font 10: RSI at +60, Status at +120
   //--- Scale proportionally: multiplier = fontSize * 6 for RSI, fontSize * 12 for status
   
   g_rsiLabelOffset = g_fontSize * 6;      // 10*6=60, 15*6=90, 20*6=120
   g_statusLabelOffset = g_fontSize * 12;  // 10*12=120, 15*12=180, 20*12=240
   
   //--- Ensure minimum offsets for readability
   g_rsiLabelOffset = MathMax(50, g_rsiLabelOffset);
   g_statusLabelOffset = MathMax(100, g_statusLabelOffset);
}

//+------------------------------------------------------------------+
//| Validate input parameters                                         |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
   bool valid = true;
   
   //--- RSI Period validation
   if(RSI_Period < 1 || RSI_Period > 500)
   {
      Print("Error: RSI_Period must be between 1 and 500. Got: ", RSI_Period);
      valid = false;
   }
   g_rsiPeriod = MathMax(1, MathMin(500, RSI_Period));
   
   //--- Level validation (check BEFORE clamping)
   if(Overbought_Level <= Oversold_Level)
   {
      Print("Error: Overbought_Level (", Overbought_Level, 
            ") must be greater than Oversold_Level (", Oversold_Level, ")");
      valid = false;
      //--- Don't clamp invalid values - return error
      return false;
   }
   
   if(Overbought_Level < 50 || Overbought_Level > 100)
   {
      Print("Warning: Overbought_Level should be between 50-100. Got: ", Overbought_Level);
   }
   if(Oversold_Level < 0 || Oversold_Level > 50)
   {
      Print("Warning: Oversold_Level should be between 0-50. Got: ", Oversold_Level);
   }
   g_obLevel = Overbought_Level;
   g_osLevel = Oversold_Level;
   
   //--- Font size validation
   if(Font_Size < 6 || Font_Size > 24)
   {
      Print("Warning: Font_Size clamped to 6-24 range. Got: ", Font_Size);
   }
   g_fontSize = MathMax(6, MathMin(24, Font_Size));
   
   //--- Update interval validation
   if(Update_Seconds < 1 || Update_Seconds > 60)
   {
      Print("Warning: Update_Seconds clamped to 1-60 range. Got: ", Update_Seconds);
   }
   g_updateSeconds = MathMax(1, MathMin(60, Update_Seconds));
   
   //--- Dashboard width validation
   if(Dashboard_Width < 150 || Dashboard_Width > 500)
   {
      Print("Warning: Dashboard_Width clamped to 150-500 range. Got: ", Dashboard_Width);
   }
   g_dashWidth = MathMax(150, MathMin(500, Dashboard_Width));
   
   //--- FIX v1.5: Dashboard position validation with robust chart dimension check
   long chartWidth = 0, chartHeight = 0;
   bool gotWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, chartWidth);
   bool gotHeight = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, chartHeight);
   
   //--- Initialize to input values
   g_dashX = Dashboard_X;
   g_dashY = Dashboard_Y;
   
   //--- Only validate if we successfully got chart dimensions
   if(gotWidth && gotHeight && chartWidth > 0 && chartHeight > 0)
   {
      if(g_dashX < 0)
      {
         if(Verbose_Logging) Print("Info: Dashboard_X adjusted from ", Dashboard_X, " to ", DEFAULT_DASH_X);
         g_dashX = DEFAULT_DASH_X;
      }
      else if(g_dashX > chartWidth - MIN_CHART_MARGIN)
      {
         g_dashX = (int)(chartWidth - g_dashWidth - DEFAULT_DASH_X);
         if(Verbose_Logging) Print("Info: Dashboard_X adjusted to ", g_dashX, " (chart edge)");
      }
      
      if(g_dashY < 0)
      {
         if(Verbose_Logging) Print("Info: Dashboard_Y adjusted from ", Dashboard_Y, " to ", DEFAULT_DASH_Y);
         g_dashY = DEFAULT_DASH_Y;
      }
      else if(g_dashY > chartHeight - MIN_CHART_MARGIN)
      {
         g_dashY = (int)(chartHeight - MIN_CHART_MARGIN - DEFAULT_DASH_Y);
         if(Verbose_Logging) Print("Info: Dashboard_Y adjusted to ", g_dashY, " (chart edge)");
      }
   }
   else
   {
      //--- Chart dimensions unavailable, use safe defaults
      if(Verbose_Logging) Print("Info: Chart dimensions unavailable, using default positions");
      if(g_dashX < 0) g_dashX = DEFAULT_DASH_X;
      if(g_dashY < 0) g_dashY = DEFAULT_DASH_Y;
   }
   
   return valid;
}

//+------------------------------------------------------------------+
//| Build timeframe arrays based on user selection                   |
//+------------------------------------------------------------------+
bool BuildTimeframeArrays()
{
   //--- Count selected timeframes first (avoid O(n²) resize)
   int count = 0;
   if(Show_M1)  count++;
   if(Show_M5)  count++;
   if(Show_M15) count++;
   if(Show_M30) count++;
   if(Show_H1)  count++;
   if(Show_H4)  count++;
   if(Show_D1)  count++;
   
   if(count == 0)
      return false;
   
   //--- Resize once with exact size
   ArrayResize(g_timeframes, count);
   ArrayResize(g_timeframeNames, count);
   
   //--- Fill arrays
   int idx = 0;
   if(Show_M1)  { g_timeframes[idx] = PERIOD_M1;  g_timeframeNames[idx] = "M1";  idx++; }
   if(Show_M5)  { g_timeframes[idx] = PERIOD_M5;  g_timeframeNames[idx] = "M5";  idx++; }
   if(Show_M15) { g_timeframes[idx] = PERIOD_M15; g_timeframeNames[idx] = "M15"; idx++; }
   if(Show_M30) { g_timeframes[idx] = PERIOD_M30; g_timeframeNames[idx] = "M30"; idx++; }
   if(Show_H1)  { g_timeframes[idx] = PERIOD_H1;  g_timeframeNames[idx] = "H1";  idx++; }
   if(Show_H4)  { g_timeframes[idx] = PERIOD_H4;  g_timeframeNames[idx] = "H4";  idx++; }
   if(Show_D1)  { g_timeframes[idx] = PERIOD_D1;  g_timeframeNames[idx] = "D1";  idx++; }
   
   return true;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   ReleaseAllHandles();
   
   //--- Remove dashboard objects
   DestroyDashboard();
   
   //--- Kill timer
   EventKillTimer();
   
   if(Verbose_Logging) Print("RSI_MultiTF_Alert v1.6 removed - Reason: ", GetDeinitReasonText(reason));
}

//+------------------------------------------------------------------+
//| Get deinitialization reason text                                  |
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason)
{
   switch(reason)
   {
      case REASON_PROGRAM:     return "Program removed";
      case REASON_REMOVE:      return "Indicator removed";
      case REASON_RECOMPILE:   return "Recompiled";
      case REASON_CHARTCHANGE: return "Symbol/period changed";
      case REASON_CHARTCLOSE:  return "Chart closed";
      case REASON_PARAMETERS:  return "Parameters changed";
      case REASON_ACCOUNT:     return "Account changed";
      case REASON_TEMPLATE:    return "Template applied";
      case REASON_INITFAILED:  return "OnInit failed";
      case REASON_CLOSE:       return "Terminal closed";
      default:                 return "Unknown (" + IntegerToString(reason) + ")";
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//| NOTE: Empty by design - all updates via OnTimer                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function - sole update mechanism                           |
//+------------------------------------------------------------------+
void OnTimer()
{
   //--- Step 1: Read all RSI values
   if(!ReadAllRSIValues())
   {
      UpdateLoadingState();
      return;
   }
   
   //--- Reset loading flag when data is ready
   g_loadingShown = false;
   
   //--- Step 2: Count OB/OS states (always, regardless of value change)
   int overboughtCount = 0;
   int oversoldCount = 0;
   CountOBOS(overboughtCount, oversoldCount);
   
   //--- Step 3: Update visual dashboard
   bool needsRedraw = UpdateVisuals();
   
   //--- Step 4: Update alignment indicator
   needsRedraw |= UpdateAlignmentIndicator(overboughtCount, oversoldCount);
   
   //--- Step 5: Check and send alerts
   CheckAlerts();
   
   //--- Step 6: Redraw if needed (FIX: consolidated single redraw)
   if(needsRedraw)
      ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Read RSI values for all timeframes                               |
//+------------------------------------------------------------------+
bool ReadAllRSIValues()
{
   int validCount = 0;
   
   for(int i = 0; i < g_tfCount; i++)
   {
      g_currentRsiValues[i] = GetRSI(g_rsiHandles[i]);
      if(g_currentRsiValues[i] >= 0)
         validCount++;
   }
   
   //--- FIX: Robust data ready check (handles edge cases like 1 TF)
   //--- Need at least 1 valid TF AND >= 50% of TFs valid
   int minRequired = (g_tfCount + 1) / 2;  // Ceiling division
   g_dataReady = (g_tfCount > 0 && validCount > 0 && validCount >= minRequired);
   return g_dataReady;
}

//+------------------------------------------------------------------+
//| Count overbought/oversold states                                  |
//+------------------------------------------------------------------+
void CountOBOS(int &obCount, int &osCount)
{
   obCount = 0;
   osCount = 0;
   
   for(int i = 0; i < g_tfCount; i++)
   {
      double rsi = g_currentRsiValues[i];
      if(rsi < 0)
         continue;
      
      if(rsi >= g_obLevel)
         obCount++;
      else if(rsi <= g_osLevel)
         osCount++;
   }
}

//+------------------------------------------------------------------+
//| Update visual elements                                            |
//+------------------------------------------------------------------+
bool UpdateVisuals()
{
   bool changed = false;
   
   for(int i = 0; i < g_tfCount; i++)
   {
      double rsi = g_currentRsiValues[i];
      
      //--- Skip if no data
      if(rsi < 0)
      {
         if(g_lastRsiValues[i] >= 0 || g_lastRsiValues[i] == -1.0)
         {
            ObjectSetString(0, g_rsiLabelNames[i], OBJPROP_TEXT, "...");
            ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_COLOR, Color_Neutral);
            ObjectSetString(0, g_statusLabelNames[i], OBJPROP_TEXT, "");
            g_lastRsiValues[i] = -2.0;
            changed = true;
         }
         continue;
      }
      
      //--- Check if value changed significantly (FIX: use constant)
      //--- Note: Comparing with >= 0 is safe here because invalid RSI is marked as -1.0 or -2.0
      //--- RSI values are always in range 0-100, so threshold of 0.1 is appropriate
      if(MathAbs(rsi - g_lastRsiValues[i]) < RSI_CHANGE_THRESHOLD && g_lastRsiValues[i] >= 0.0)
         continue;
      
      g_lastRsiValues[i] = rsi;
      changed = true;
      
      //--- Update RSI value text
      ObjectSetString(0, g_rsiLabelNames[i], OBJPROP_TEXT, DoubleToString(rsi, 1));
      
      //--- Determine color and status
      color textColor = Color_Neutral;
      string status = "";
      
      if(rsi >= g_obLevel)
      {
         textColor = Color_Overbought;
         status = "▲ OB";
      }
      else if(rsi <= g_osLevel)
      {
         textColor = Color_Oversold;
         status = "▼ OS";
      }
      
      ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_COLOR, textColor);
      ObjectSetString(0, g_statusLabelNames[i], OBJPROP_TEXT, status);
      ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_COLOR, textColor);
   }
   
   return changed;
}

//+------------------------------------------------------------------+
//| Update alignment indicator (FIX: uses global state vars + const) |
//+------------------------------------------------------------------+
bool UpdateAlignmentIndicator(int obCount, int osCount)
{
   //--- Check if changed (using global vars instead of static)
   if(obCount == g_lastOBCount && osCount == g_lastOSCount)
      return false;
   
   g_lastOBCount = obCount;
   g_lastOSCount = osCount;
   
   string alignText = "";
   color alignColor = clrGold;
   
   //--- FIX: Use constant for threshold
   if(obCount >= ALIGNMENT_THRESHOLD)
   {
      alignText = StringFormat("⚠ %d TF OVERBOUGHT", obCount);
      alignColor = Color_Overbought;
   }
   else if(osCount >= ALIGNMENT_THRESHOLD)
   {
      alignText = StringFormat("⚠ %d TF OVERSOLD", osCount);
      alignColor = Color_Oversold;
   }
   
   ObjectSetString(0, g_alignName, OBJPROP_TEXT, alignText);
   ObjectSetInteger(0, g_alignName, OBJPROP_COLOR, alignColor);
   
   return true;
}

//+------------------------------------------------------------------+
//| Update loading state display (FIX: uses global flag)             |
//+------------------------------------------------------------------+
void UpdateLoadingState()
{
   //--- Only show loading message once (using global instead of static)
   if(!g_loadingShown)
   {
      ObjectSetString(0, g_alignName, OBJPROP_TEXT, "⏳ Loading data...");
      ObjectSetInteger(0, g_alignName, OBJPROP_COLOR, clrYellow);
      ChartRedraw(0);
      g_loadingShown = true;
   }
}

//+------------------------------------------------------------------+
//| Check and send alerts for all timeframes                         |
//+------------------------------------------------------------------+
void CheckAlerts()
{
   for(int i = 0; i < g_tfCount; i++)
   {
      double rsi = g_currentRsiValues[i];
      if(rsi < 0)
         continue;
      
      if(rsi >= g_obLevel)
         TrySendAlert(i, "OVERBOUGHT", rsi);
      else if(rsi <= g_osLevel)
         TrySendAlert(i, "OVERSOLD", rsi);
   }
}

//+------------------------------------------------------------------+
//| Try to send alert (with anti-spam protection and retry logic)    |
//+------------------------------------------------------------------+
void TrySendAlert(int tfIndex, const string condition, double rsiValue)
{
   //--- Get current bar time
   datetime currentBarTime = iTime(_Symbol, g_timeframes[tfIndex], 0);
   
   //--- FIX: If iTime returns 0, throttle warnings to avoid log spam
   if(currentBarTime == 0)
   {
      datetime now = TimeCurrent();
      if(now - g_lastItimeWarning[tfIndex] >= ITIME_WARNING_COOLDOWN)
      {
         if(Verbose_Logging) Print("Debug: iTime returned 0 for ", g_timeframeNames[tfIndex], " - skipping alert");
         g_lastItimeWarning[tfIndex] = now;
      }
      return;
   }
   
   //--- Only alert once per bar (anti-spam)
   if(g_lastAlertTime[tfIndex] == currentBarTime)
      return;
   
   g_lastAlertTime[tfIndex] = currentBarTime;
   
   //--- Prepare alert message
   string message = StringFormat("%s %s RSI %s: %.1f",
                                  _Symbol,
                                  g_timeframeNames[tfIndex],
                                  condition,
                                  rsiValue);
   
   //--- Send sound alert
   if(Enable_Sound_Alerts)
   {
      SendSoundWithRetry(Alert_Sound);
   }
   
   //--- Send push notification with retry
   if(Enable_Push_Alerts)
   {
      SendPushWithRetry(message);
   }
   
   //--- Send email with retry
   if(Enable_Email_Alerts)
   {
      SendEmailWithRetry("RSI Alert: " + _Symbol, message);
   }
   
   //--- Print to terminal (always, this is the main alert log)
   Print("ALERT: ", message);
}

//+------------------------------------------------------------------+
//| Send sound alert with retry logic                                 |
//+------------------------------------------------------------------+
void SendSoundWithRetry(const string soundFile)
{
   int retries = Alert_Retry_Enabled ? ALERT_MAX_RETRIES : 0;
   
   for(int attempt = 0; attempt <= retries; attempt++)
   {
      ResetLastError();
      if(PlaySound(soundFile))
         return;  // Success
      
      int err = GetLastError();
      if(err == 0)
         return;  // No error, assume success
      
      //--- Log on last attempt only (avoid spam)
      if(attempt == retries)
      {
         if(Verbose_Logging) Print("Warning: PlaySound failed for '", soundFile, "' after ", attempt + 1, " attempts - Error: ", err);
      }
      else
      {
         Sleep(ALERT_RETRY_DELAY_MS);
      }
   }
}

//+------------------------------------------------------------------+
//| Send push notification with retry logic                           |
//+------------------------------------------------------------------+
void SendPushWithRetry(const string message)
{
   int retries = Alert_Retry_Enabled ? ALERT_MAX_RETRIES : 0;
   
   for(int attempt = 0; attempt <= retries; attempt++)
   {
      ResetLastError();
      if(SendNotification(message))
         return;  // Success
      
      int err = GetLastError();
      
      //--- Don't retry configuration errors
      if(err == 4515)
      {
         if(Verbose_Logging) Print("Info: Push notifications not configured in terminal");
         return;
      }
      
      //--- Log on last attempt only
      if(attempt == retries)
      {
         if(Verbose_Logging) Print("Warning: SendNotification failed after ", attempt + 1, " attempts - Error: ", err);
      }
      else
      {
         Sleep(ALERT_RETRY_DELAY_MS);
      }
   }
}

//+------------------------------------------------------------------+
//| Send email with retry logic                                       |
//+------------------------------------------------------------------+
void SendEmailWithRetry(const string subject, const string body)
{
   int retries = Alert_Retry_Enabled ? ALERT_MAX_RETRIES : 0;
   
   for(int attempt = 0; attempt <= retries; attempt++)
   {
      ResetLastError();
      if(SendMail(subject, body))
         return;  // Success
      
      int err = GetLastError();
      
      //--- Don't retry configuration errors
      if(err == 4510)
      {
         if(Verbose_Logging) Print("Info: Email not configured in terminal");
         return;
      }
      
      //--- Log on last attempt only
      if(attempt == retries)
      {
         if(Verbose_Logging) Print("Warning: SendMail failed after ", attempt + 1, " attempts - Error: ", err);
      }
      else
      {
         Sleep(ALERT_RETRY_DELAY_MS);
      }
   }
}

//+------------------------------------------------------------------+
//| Get RSI value from handle (FIX: uses BarsCalculated)             |
//+------------------------------------------------------------------+
double GetRSI(int handle, int shift = 0)
{
   if(handle == INVALID_HANDLE)
      return -1.0;
   
   //--- FIX: Check if indicator has calculated bars
   int calculated = BarsCalculated(handle);
   if(calculated <= 0)
   {
      //--- Indicator still calculating or error
      if(calculated == 0)
         return -1.0;  // Still calculating, silent
      else
      {
         //--- calculated < 0 means error
         int err = GetLastError();
         if(err != 0)
            Print("Warning: BarsCalculated error for handle ", handle, " - Error: ", err);
         return -1.0;
      }
   }
   
   double rsiBuffer[1];
   
   ResetLastError();
   if(CopyBuffer(handle, 0, shift, 1, rsiBuffer) != 1)
   {
      return -1.0;
   }
   
   return rsiBuffer[0];
}

//+------------------------------------------------------------------+
//| Get error description                                             |
//+------------------------------------------------------------------+
string ErrorDescription(int errorCode)
{
   switch(errorCode)
   {
      case 0:     return "No error";
      case 4301:  return "Unknown symbol";
      case 4302:  return "Symbol not selected";
      case 4401:  return "Indicator buffer error";
      case 4402:  return "Invalid indicator handle";
      case 4806:  return "Requested data not found";
      default:    return "Error " + IntegerToString(errorCode);
   }
}

//+------------------------------------------------------------------+
//| Create dashboard objects (FIX: uses OBJPROP_HIDDEN + validated pos)
//+------------------------------------------------------------------+
void CreateDashboard()
{
   int xPos = g_dashX;  // FIX: use validated position
   int yPos = g_dashY;
   int lineHeight = g_fontSize + LINE_HEIGHT_PADDING;
   //--- FIX: Use constant for padding calculation
   int dashHeight = (g_tfCount + 2) * lineHeight + DASHBOARD_PADDING;
   
   //--- Background rectangle
   if(ObjectCreate(0, g_bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, g_bgName, OBJPROP_XDISTANCE, xPos - DASHBOARD_MARGIN);
      ObjectSetInteger(0, g_bgName, OBJPROP_YDISTANCE, yPos - DASHBOARD_MARGIN);
      ObjectSetInteger(0, g_bgName, OBJPROP_XSIZE, g_dashWidth);
      ObjectSetInteger(0, g_bgName, OBJPROP_YSIZE, dashHeight);
      ObjectSetInteger(0, g_bgName, OBJPROP_BGCOLOR, Color_Background);
      ObjectSetInteger(0, g_bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, g_bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_bgName, OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, g_bgName, OBJPROP_BACK, false);
      ObjectSetInteger(0, g_bgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_bgName, OBJPROP_HIDDEN, true);  // FIX: hide from object list
      ObjectSetInteger(0, g_bgName, OBJPROP_ZORDER, 0);
   }
   
   //--- Title label
   if(ObjectCreate(0, g_titleName, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, g_titleName, OBJPROP_XDISTANCE, xPos);
      ObjectSetInteger(0, g_titleName, OBJPROP_YDISTANCE, yPos);
      ObjectSetInteger(0, g_titleName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_titleName, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, g_titleName, OBJPROP_FONTSIZE, g_fontSize + TITLE_FONT_BOOST);
      ObjectSetString(0, g_titleName, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, g_titleName, OBJPROP_TEXT, "RSI Multi-TF (" + _Symbol + ")");
      ObjectSetInteger(0, g_titleName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_titleName, OBJPROP_HIDDEN, true);  // FIX
      ObjectSetInteger(0, g_titleName, OBJPROP_ZORDER, 1);
   }
   
   yPos += lineHeight + LINE_SPACING_EXTRA;
   
   //--- Create labels for each timeframe
   for(int i = 0; i < g_tfCount; i++)
   {
      //--- Timeframe name label
      if(ObjectCreate(0, g_tfLabelNames[i], OBJ_LABEL, 0, 0, 0))
      {
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_XDISTANCE, xPos);
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_YDISTANCE, yPos);
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_FONTSIZE, g_fontSize);
         ObjectSetString(0, g_tfLabelNames[i], OBJPROP_FONT, "Arial");
         ObjectSetString(0, g_tfLabelNames[i], OBJPROP_TEXT, g_timeframeNames[i] + ":");
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_HIDDEN, true);  // FIX
         ObjectSetInteger(0, g_tfLabelNames[i], OBJPROP_ZORDER, 1);
      }
      
      //--- RSI value label (FIX: proportional offset)
      if(ObjectCreate(0, g_rsiLabelNames[i], OBJ_LABEL, 0, 0, 0))
      {
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_XDISTANCE, xPos + g_rsiLabelOffset);
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_YDISTANCE, yPos);
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_COLOR, Color_Neutral);
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_FONTSIZE, g_fontSize);
         ObjectSetString(0, g_rsiLabelNames[i], OBJPROP_FONT, "Arial Bold");
         ObjectSetString(0, g_rsiLabelNames[i], OBJPROP_TEXT, "...");
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_HIDDEN, true);  // FIX
         ObjectSetInteger(0, g_rsiLabelNames[i], OBJPROP_ZORDER, 1);
      }
      
      //--- Status label (FIX: proportional offset)
      if(ObjectCreate(0, g_statusLabelNames[i], OBJ_LABEL, 0, 0, 0))
      {
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_XDISTANCE, xPos + g_statusLabelOffset);
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_YDISTANCE, yPos);
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_COLOR, Color_Neutral);
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_FONTSIZE, g_fontSize);
         ObjectSetString(0, g_statusLabelNames[i], OBJPROP_FONT, "Arial");
         ObjectSetString(0, g_statusLabelNames[i], OBJPROP_TEXT, "");
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_HIDDEN, true);  // FIX
         ObjectSetInteger(0, g_statusLabelNames[i], OBJPROP_ZORDER, 1);
      }
      
      yPos += lineHeight;
   }
   
   //--- Alignment status label
   if(ObjectCreate(0, g_alignName, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, g_alignName, OBJPROP_XDISTANCE, xPos);
      ObjectSetInteger(0, g_alignName, OBJPROP_YDISTANCE, yPos + LINE_SPACING_EXTRA);
      ObjectSetInteger(0, g_alignName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_alignName, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, g_alignName, OBJPROP_FONTSIZE, g_fontSize);
      ObjectSetString(0, g_alignName, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, g_alignName, OBJPROP_TEXT, "⏳ Initializing...");
      ObjectSetInteger(0, g_alignName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_alignName, OBJPROP_HIDDEN, true);  // FIX
      ObjectSetInteger(0, g_alignName, OBJPROP_ZORDER, 1);
   }
   
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Destroy dashboard objects                                         |
//+------------------------------------------------------------------+
void DestroyDashboard()
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
