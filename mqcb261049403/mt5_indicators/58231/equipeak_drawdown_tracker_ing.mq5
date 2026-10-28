//+------------------------------------------------------------------+ 
//|                              Copyright 2025, Enrique Enguix      |
//|                              https://www.mql5.com/es/users/envex |
//+------------------------------------------------------------------+
#property copyright   "(c) 2025 Enrique Enguix"
#property link        "https://www.mql5.com/es/users/envex"
#property version     "1.02"
#property description "Tracks current/historical drawdown, with logs and push notifications."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

#include <Trade\PositionInfo.mqh>

//+------------------------------------------------------------------+
//| Position info object                                             |
//+------------------------------------------------------------------
CPositionInfo g_position;

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------
enum EBalanceMode
  {
   REF_FIXED_BALANCE = 0, // Use a fixed balance reference
   REF_PEAK_BALANCE  = 1  // Use a peak balance reference (global variable)
  };

enum EMaxDDUpdateMode
  {
   NO_UPDATE_MAX_DD        = 0, // Do not update the historical Max DD
   UPDATE_MAX_DD_IF_BIGGER = 1  // Update if current DD exceeds the historical DD
  };

//+------------------------------------------------------------------+
//| Enumeration for file extension selection                         |
//+------------------------------------------------------------------
enum SFileExtension
  {
   UseCSV = 0, // Use CSV format (Excel-friendly)
   UseTXT = 1  // Use TXT format (plain text)
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------
input string  MagicNumbers               = "-1"; // Magics to monitor (-1 tracks all)
input double  InitialMaxDrawdown         = 0.0;  // Initial Max DD (%)
input uint    RefreshInterval            = 60;   // Update frequency (seconds)
input EMaxDDUpdateMode UpdateMaxDrawdown = UPDATE_MAX_DD_IF_BIGGER; // MaxDD update mode
input bool    SendPushNotifications      = true; // Send push notifications?

//--- Reference balance mode
input EBalanceMode ReferenceBalanceMode   = REF_FIXED_BALANCE; // Fixed or peak reference?
input double       InpFixedBalance        = 0.0;  // Fixed balance (0 => current)

//--- Visual style
input color CurrentDrawdownTextColor      = clrGray; // Color for current DD text
input color MaxDrawdownTextColor          = clrGray; // Color for max DD text
input uint  CurrentDrawdownFontSize       = 25;      // Font size (current DD)
input uint  MaxDrawdownFontSize           = 25;      // Font size (max DD)
input bool  DisplayLabelsInBackground     = true;    // Labels behind the chart?

//--- Label position & spacing
input int   LabelPosX                     = 200; // Label X (pixels)
input int   LabelPosY                     = 20;  // Label Y (pixels)
input uint  LabelSpacing                  = 10;  // Vertical spacing

//--- Log detail level
input bool  PrintDetailedLogs             = true; // Print logs in Journal?

//--- New inputs for file logging
input bool           EnableFileLog        = true;   // Create a separate file to log current drawdown values
input SFileExtension InpFileExtension     = UseTXT; // File extension: CSV or TXT

//+------------------------------------------------------------------+
//| Global variables (not user inputs)                               |
//+------------------------------------------------------------------
double g_ReferenceBalance      = 0.0;  // Reference balance used for DD calculations
double g_MaxDrawdown           = 0.0;  // Max historical drawdown (%), stored globally
double g_PeakBalance           = 0.0;  // Peak balance (if using REF_PEAK_BALANCE)

// Global variable names with a unique suffix (avoid conflicts among instances)
string g_PeakBalanceGVName;
string g_MaxDrawdownGVName;

// We'll store extensions and other parameters internally
uint   g_RefreshIntervalVar      = 60;
uint   g_CurrentDrawdownFontSize = 35;
uint   g_MaxDrawdownFontSize     = 35;
string g_FileExtension           = ".csv"; // default value

// Names of text objects with a unique suffix (ChartID)
string g_currentDrawdownObjName;
string g_maxDrawdownObjName;

// Spam control in NO_UPDATE_MAX_DD mode (1 notification every 60 minutes)
datetime g_LastPushTimeNOUPDATE = 0;

//+------------------------------------------------------------------+
//| OnInit: Initialization                                           |
//+------------------------------------------------------------------
int OnInit()
  {
   // Build unique suffixes for global variables (using ChartID for distinction)
   g_PeakBalanceGVName    = "EquiPeakDT_PeakBalance_" + (string)ChartID();
   g_MaxDrawdownGVName    = "EquiPeakDT_MaxDD_"       + (string)ChartID();

   // Also assign unique text object names
   g_currentDrawdownObjName = "current_drawdown_" + (string)ChartID();
   g_maxDrawdownObjName     = "max_drawdown_"     + (string)ChartID();

   //--- Validate RefreshInterval
   if(RefreshInterval < 1)
     {
      g_RefreshIntervalVar = 10;
      if(PrintDetailedLogs)
         Print("[WARNING] RefreshInterval < 1. Using 10 seconds as a minimum fallback.");
     }
   else
      if(RefreshInterval > 3600)
        {
         g_RefreshIntervalVar = 3600;
         if(PrintDetailedLogs)
            Print("[WARNING] RefreshInterval > 3600. Using 3600 seconds (1 hour) as max.");
        }
      else
        {
         g_RefreshIntervalVar = RefreshInterval;
        }

   //--- Validate CurrentDrawdownFontSize
   if(CurrentDrawdownFontSize < 1)
     {
      g_CurrentDrawdownFontSize = 12;
      if(PrintDetailedLogs)
         Print("[WARNING] CurrentDrawdownFontSize <1. Using 12 as a fallback value.");
     }
   else
     {
      g_CurrentDrawdownFontSize = CurrentDrawdownFontSize;
     }

   //--- Validate MaxDrawdownFontSize
   if(MaxDrawdownFontSize < 1)
     {
      g_MaxDrawdownFontSize = 12;
      if(PrintDetailedLogs)
         Print("[WARNING] MaxDrawdownFontSize <1. Using 12 as a fallback value.");
     }
   else
     {
      g_MaxDrawdownFontSize = MaxDrawdownFontSize;
     }

   //--- Determine file extension from enum
   if(InpFileExtension == UseCSV)
      g_FileExtension = ".csv";
   else
      g_FileExtension = ".txt";

   //--- Set the timer with the validated interval
   EventSetTimer(g_RefreshIntervalVar);

   //--- Call OnTimer once so it draws/logs immediately
   OnTimer();

   //--- Configure / read the peak balance if using REF_PEAK_BALANCE
   if(ReferenceBalanceMode == REF_PEAK_BALANCE)
     {
      if(GlobalVariableCheck(g_PeakBalanceGVName))
        {
         g_PeakBalance = GlobalVariableGet(g_PeakBalanceGVName);
         if(PrintDetailedLogs)
            PrintFormat("[INFO] Loaded peak balance from global variable: %.2f", g_PeakBalance);
        }
      else
        {
         g_PeakBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         GlobalVariableSet(g_PeakBalanceGVName, g_PeakBalance);
         if(PrintDetailedLogs)
            PrintFormat("[INFO] No global variable found. Created initial peak balance: %.2f", g_PeakBalance);
        }
     }

   //--- Load or create the global variable for Max Drawdown
   if(GlobalVariableCheck(g_MaxDrawdownGVName))
     {
      g_MaxDrawdown = GlobalVariableGet(g_MaxDrawdownGVName);
      if(PrintDetailedLogs)
         PrintFormat("[INFO] Loaded max historical DD from global variable: %.2f%%", g_MaxDrawdown);
     }
   else
     {
      g_MaxDrawdown = InitialMaxDrawdown;
      GlobalVariableSet(g_MaxDrawdownGVName, g_MaxDrawdown);
      if(PrintDetailedLogs)
         PrintFormat("[INFO] No global variable found for max DD. Created initial with: %.2f%%", g_MaxDrawdown);
     }

   //--- Determine reference balance
   if(ReferenceBalanceMode == REF_FIXED_BALANCE)
     {
      if(InpFixedBalance <= 0.0)
        {
         double fallback = AccountInfoDouble(ACCOUNT_BALANCE);
         g_ReferenceBalance = fallback;
         if(PrintDetailedLogs)
            PrintFormat("[WARNING] InpFixedBalance <= 0. Using current account balance instead (%.2f).",
                        fallback);
        }
      else
        {
         g_ReferenceBalance = InpFixedBalance;
         if(PrintDetailedLogs)
            PrintFormat("[INFO] Using Fixed Balance mode. Reference = %.2f", g_ReferenceBalance);
        }
     }
   else // REF_PEAK_BALANCE
     {
      g_ReferenceBalance = g_PeakBalance;
      if(PrintDetailedLogs)
         PrintFormat("[INFO] Using Peak Balance mode. Reference = %.2f", g_ReferenceBalance);
     }

   //--- Avoid division by zero
   if(g_ReferenceBalance < 1e-8)
     {
      g_ReferenceBalance = 1e-8; // minimal fallback
      if(PrintDetailedLogs)
         Print("[ERROR] Reference balance was 0 or invalid. Set to 1e-8 to avoid division by zero.");
     }

   //--- Final initialization message
   if(PrintDetailedLogs)
     {
      Print("[INFO] EquiPeakDrawdownTracker successfully initialized.");
      PrintConfigurationSummary();
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnTimer: Called every RefreshInterval seconds                    |
//+------------------------------------------------------------------
void OnTimer()
  {
   double realBalance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfit = GetFloatingProfit();
   double accountEquity  = realBalance + floatingProfit;

   //--- If using PeakBalance, check for a new peak (closed balance)
   if(ReferenceBalanceMode == REF_PEAK_BALANCE)
     {
      if(realBalance > g_PeakBalance)
        {
         double oldPeak     = g_PeakBalance;
         g_PeakBalance      = realBalance;
         GlobalVariableSet(g_PeakBalanceGVName, g_PeakBalance);
         g_ReferenceBalance = g_PeakBalance; // update reference

         if(PrintDetailedLogs)
            PrintFormat("[INFO] New peak balance detected: %.2f (old peak was %.2f)",
                        g_PeakBalance, oldPeak);
        }
     }

   //--- Calculate current drawdown
   double currentDrawdownPct = CalculateCurrentDrawdownPct(accountEquity, g_ReferenceBalance);

   //--- Update max drawdown logic
   if(UpdateMaxDrawdown == UPDATE_MAX_DD_IF_BIGGER)
     {
      // If current DD is higher than the historical DD
      if(currentDrawdownPct > g_MaxDrawdown)
        {
         double oldMax = g_MaxDrawdown;
         g_MaxDrawdown = currentDrawdownPct;
         GlobalVariableSet(g_MaxDrawdownGVName, g_MaxDrawdown);

         if(PrintDetailedLogs)
            PrintFormat("[INFO] New max drawdown reached: %.2f%% (old max was %.2f%%)",
                        g_MaxDrawdown, oldMax);

         // Send push notification (only if configured)
         if(SendPushNotifications)
            SendDetailedNotification(currentDrawdownPct, oldMax, true);
        }
     }
   else // NO_UPDATE_MAX_DD
     {
      // Send notification only every 60 minutes (3600 sec)
      if(SendPushNotifications)
        {
         if((TimeCurrent() - g_LastPushTimeNOUPDATE) >= 3600)
           {
            SendDetailedNotification(currentDrawdownPct, g_MaxDrawdown, false);
            g_LastPushTimeNOUPDATE = TimeCurrent();
           }
        }
     }

   //--- (1) Update chart labels
   string currentDDText = StringFormat("Current Drawdown: %.2f%%", currentDrawdownPct);
   string maxDDText     = StringFormat("Max. Historical Drawdown: %.2f%%", g_MaxDrawdown);

   // Label 1: current drawdown
   DrawLabel(g_currentDrawdownObjName,
             currentDDText,
             LabelPosX,
             LabelPosY,
             CurrentDrawdownTextColor,
             g_CurrentDrawdownFontSize);

   // Label 2: max drawdown
   int secondLabelY = LabelPosY + (int)g_CurrentDrawdownFontSize + (int)LabelSpacing;
   DrawLabel(g_maxDrawdownObjName,
             maxDDText,
             LabelPosX,
             secondLabelY,
             MaxDrawdownTextColor,
             g_MaxDrawdownFontSize);

   //--- (2) Log to file if enabled
   if(EnableFileLog)
      LogDrawdown(currentDrawdownPct);
  }

//+------------------------------------------------------------------+
//| OnDeinit: Final cleanup                                          |
//+------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, g_currentDrawdownObjName);
   ObjectDelete(0, g_maxDrawdownObjName);

   if(PrintDetailedLogs)
      Print("[INFO] EquiPeakDrawdownTracker deinitialized.");
  }

//+------------------------------------------------------------------+
//| OnCalculate: Indicator function (not used for plotting)          |
//+------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   // This indicator does not draw any buffers.
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| CalculateCurrentDrawdownPct: Returns the floating DD in %        |
//+------------------------------------------------------------------
double CalculateCurrentDrawdownPct(const double equity, const double referenceBalance)
  {
   double eps  = 1e-10;
   double diff = referenceBalance - equity;

   if(diff <= eps)
      return 0.0; // no drawdown if equity >= referenceBalance (or nearly so)

   return (diff / referenceBalance) * 100.0;
  }

//+------------------------------------------------------------------+
//| GetFloatingProfit: Returns total floating profit for the tracked |
//| magic numbers                                                    |
//+------------------------------------------------------------------
double GetFloatingProfit()
  {
   double totalProfit = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!g_position.SelectByIndex(i))
        {
         if(PrintDetailedLogs)
            PrintFormat("[WARNING] Unable to select position at index %d", i);
         continue;
        }

      long mNumber = g_position.Magic();
      if(IsTrackedMagicNumber(mNumber))
        {
         // Profit() already includes swap and commissions
         totalProfit += g_position.Profit();
        }
     }
   return totalProfit;
  }

//+------------------------------------------------------------------+
//| IsTrackedMagicNumber: Compares the magic number with the list    |
//| (or -1)                                                          |
//+------------------------------------------------------------------
bool IsTrackedMagicNumber(long magicNumber)
  {
   string magicList[];
   int count = StringSplit(MagicNumbers, ',', magicList);
   bool trackAll = false;

   //--- First check if "-1" is in the list
   for(int i = 0; i < count; i++)
     {
      string magicStr = magicList[i];
      StringReplace(magicStr, " ", ""); // remove spaces
      if(magicStr == "-1")
        {
         trackAll = true;
         break;
        }
     }

   if(trackAll)
      return true;

   //--- Otherwise compare with each value
   for(int i = 0; i < count; i++)
     {
      string magicStr = magicList[i];
      StringReplace(magicStr, " ", "");

      double parsed = StringToDouble(magicStr);
      if(parsed == (double)magicNumber)
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| SendDetailedNotification: Sends a push message with more details |
//+------------------------------------------------------------------
void SendDetailedNotification(double currentDD, double oldMaxDD, bool isNewRecord)
  {
   string server  = AccountInfoString(ACCOUNT_SERVER);
   long   login   = AccountInfoInteger(ACCOUNT_LOGIN);
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);

   // More comprehensive message
   string msg = StringFormat(
                   "EquiPeak Drawdown Tracker v1.00\nBroker/Server: %s\nAccount: %lld\nTime: %s\n"
                   "Current DD: %.2f%%\nMax Historical DD: %.2f%%",
                   server,
                   login,
                   timeStr,
                   currentDD,
                   g_MaxDrawdown
                );

   if(isNewRecord)
      msg += StringFormat("\n[RECORD] New Max DD reached! (previous was %.2f%%)", oldMaxDD);

   bool sent = SendNotification(msg);
   if(!sent && PrintDetailedLogs)
     {
      PrintFormat("[WARNING] Failed to send push notification: %s", msg);
     }
  }

//+------------------------------------------------------------------+
//| PrintConfigurationSummary: Displays the chosen configuration     |
//+------------------------------------------------------------------
void PrintConfigurationSummary()
  {
   if(!PrintDetailedLogs)
      return;

   Print("===== EquiPeak Drawdown Tracker Configuration Summary =====");

   // Magic numbers
   PrintFormat(" > MagicNumbers to track: %s", MagicNumbers);

   // Balance Mode
   if(ReferenceBalanceMode == REF_FIXED_BALANCE)
      PrintFormat(" > Balance Mode: FIXED, reference balance = %.2f", g_ReferenceBalance);
   else
      PrintFormat(" > Balance Mode: PEAK (loaded peak = %.2f)", g_PeakBalance);

   // Max DD update mode
   if(UpdateMaxDrawdown == UPDATE_MAX_DD_IF_BIGGER)
      Print(" > MaxDD Update Mode: UPDATE IF BIGGER");
   else
      Print(" > MaxDD Update Mode: DO NOT UPDATE (with limited notifications)");

   // Current Max Drawdown
   PrintFormat(" > Current stored Max DD = %.2f%%", g_MaxDrawdown);

   // Refresh interval
   PrintFormat(" > Refresh interval (seconds): %u", g_RefreshIntervalVar);

   // Push notifications
   PrintFormat(" > Push Notifications: %s", SendPushNotifications ? "ENABLED" : "DISABLED");

   // Labels
   PrintFormat(" > Label Text Sizes (DD/MaxDD): %u / %u", g_CurrentDrawdownFontSize, g_MaxDrawdownFontSize);
   PrintFormat(" > Label Positions: X=%d, Y=%d, Spacing=%u", LabelPosX, LabelPosY, LabelSpacing);

   // File logging
   PrintFormat(" > File Logging: %s", EnableFileLog ? "ENABLED" : "DISABLED");
   if(EnableFileLog)
     {
      string tf = PeriodToStringLowerCase(_Period);
      string fileName = "DD_" + _Symbol + "_" + tf + "_Magic_" + MagicNumbers + g_FileExtension;
      PrintFormat(" > File Extension: %s", g_FileExtension);
      PrintFormat(" > File Path (approx.): Common/Files/%s", fileName);
     }

   Print("==========================================================");
  }

//+------------------------------------------------------------------+
//| LogDrawdown: Append DD info to a file (CSV or TXT)              |
//+------------------------------------------------------------------
void LogDrawdown(double currentDrawdown)
  {
   string symbol    = _Symbol;
   string tfString  = PeriodToStringLowerCase(_Period);
   string fileName  = "DD_" + symbol + "_" + tfString + "_Magic_" + MagicNumbers + g_FileExtension;

   int flags = FILE_READ | FILE_WRITE | FILE_COMMON;
   if(g_FileExtension == ".csv")
      flags |= FILE_CSV;

   int handle = FileOpen(fileName, flags);
   if(handle == INVALID_HANDLE)
     {
      Print("[ERROR] Could not open/create log file: ", fileName);
      return;
     }

   FileSeek(handle, 0, SEEK_END);
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);

   // Get Balance and Equity values
   double realBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = realBalance + GetFloatingProfit();

   // Write to file: we append Balance and Equity to the log line
   FileWrite(handle, timeStr, MagicNumbers, DoubleToString(currentDrawdown, 2),
             DoubleToString(realBalance, 2), DoubleToString(equity, 2));
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------
string PeriodToStringLowerCase(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1:
         return "m1";
      case PERIOD_M2:
         return "m2";
      case PERIOD_M3:
         return "m3";
      case PERIOD_M4:
         return "m4";
      case PERIOD_M5:
         return "m5";
      case PERIOD_M6:
         return "m6";
      case PERIOD_M10:
         return "m10";
      case PERIOD_M12:
         return "m12";
      case PERIOD_M15:
         return "m15";
      case PERIOD_M20:
         return "m20";
      case PERIOD_M30:
         return "m30";
      case PERIOD_H1:
         return "h1";
      case PERIOD_H2:
         return "h2";
      case PERIOD_H3:
         return "h3";
      case PERIOD_H4:
         return "h4";
      case PERIOD_H6:
         return "h6";
      case PERIOD_H8:
         return "h8";
      case PERIOD_H12:
         return "h12";
      case PERIOD_D1:
         return "d1";
      case PERIOD_W1:
         return "w1";
      case PERIOD_MN1:
         return "mn1";
      default:
         return "unknown";
     }
  }

//+------------------------------------------------------------------+
//| DrawLabel: Creates/updates a label on the chart                  |
//+------------------------------------------------------------------
void DrawLabel(string name,
               string text,
               int x,
               int y,
               color clr,
               uint fontSize)
  {
   if(ObjectFind(0, name) == -1)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_BACK, DisplayLabelsInBackground);
     }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
