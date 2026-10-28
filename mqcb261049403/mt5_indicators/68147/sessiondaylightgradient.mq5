//+------------------------------------------------------------------+
//|                                    Session-Daylight-Gradient.mq5 |
//|                          Session Daylight Gradient MT5 Indicator |
//|                                           stratcorealpha project |
//+------------------------------------------------------------------+
#property copyright "Developed by stratcorealpha | https://www.mql5.com/de/users/stratcorealpha | https://stratcorealpha.com/"
#property link      "https://stratcorealpha.com/"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Dummy
#property indicator_label1  "Dummy"
#property indicator_type1   DRAW_NONE
#property strict
#property description "Session Daylight Gradient - Ambient market session indicator with smooth color transitions"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
// Note: No external includes required for this indicator

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== General Settings ==="
input bool   EnableGradient = true;
input bool   EnableSunrays = false;
input string SessionTimeMode = "UTC"; // Session Reference Time Mode
input int    ManualDSTShiftHours = 0; // Manual DST Shift (+1, -1, or 0)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "=== Session Times (HH:MM format) ==="
input string AsiaStart = "00:00";
input string AsiaEnd = "07:00";
input string LondonOpenStart = "07:00";
input string LondonOpenEnd = "09:00";
input string OverlapStart = "12:00";
input string OverlapEnd = "16:00";
input string NYCloseStart = "16:00";
input string NYCloseEnd = "21:00";
input string PacificStart = "21:00"; // Previously NightStart
input string PacificEnd = "06:00";   // New Pacific End

input group "=== Colors & Visual Intensity ==="
input color  PacificColor = clrMidnightBlue; // Pacific (Quiet/Night)
input color  AsiaColor    = clrDarkTurquoise;// Asia (Consolidation)
input color  LondonColor  = clrSilver;       // London (Activity)
input color  NYColor      = clrMediumOrchid; // NY (Volatility)
input uchar  MaxOpacity = 50; // Background opacity (0-255)
input int    SmoothingStrength = 6; // Transition smoothness (1-10)
input bool   ApplyToMainChartOnly = true;

input group "=== Visual Separators ==="
input bool   ShowSessionLines = true; // Draw vertical lines at session start/end
input color  SessionLineColor = clrRed; // Color of the separator lines
input ENUM_LINE_STYLE SessionLineStyle = STYLE_SOLID; // Style (Dot/Dash/Solid)
input int    SessionLineWidth = 2; // Width of the separator lines

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "=== Sunray Settings (News Highlights) ==="
input string SunrayTimes = ""; // Format: "2026-01-11 14:30; 16:00" or "14:30; 16:00"
input int    SunrayWidthMinutes = 3;
input uchar  SunrayOpacity = 40;
input color  SunrayColor = clrGold;
input string SunrayLabelMode = "None"; // Sunray labels: None/TimeOnly/CustomText

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string indicatorPrefix = "sdg_";
int serverToUtcOffset = 0;
int pcToUtcOffset = 0;
datetime lastUpdateTime = 0;

// Session time storage
int sessionTimes[5][2]; // [session][start/end in minutes]
bool sessionValid[5] = {false};

// Sunray storage
datetime sunrayTimes[];
int sunrayCount = 0;

// Chart properties
int chartWidth = 0;
int chartHeight = 0;
int lastVisibleBars = -1;
int lastFirstVisibleBar = -1;
double lastChartMin = 0;
double lastChartMax = 0;

// Cached time array reference and rates_total from OnCalculate
datetime cachedTime[];
int cachedRatesTotal = 0;
bool hasCachedData = false;

// Dummy buffer for MQL5 compatibility
double dummyBuffer[];

// Forward declaration
void CreateGradientObjects(const datetime &time[], const int rates_total);

//+------------------------------------------------------------------+
//| Helper: Convert HH:MM to minutes                                 |
//+------------------------------------------------------------------+
int TimeStringToMinutes(const string& inputTimeStr)
  {
   if(StringLen(inputTimeStr) < 3)
      return -1;

   string cleanStr = inputTimeStr;
   StringTrimLeft(cleanStr);
   StringTrimRight(cleanStr);

   int strLen = StringLen(cleanStr);
   if(strLen > 5)
      return -1;

   int colonPos = StringFind(cleanStr, ":");
   if(colonPos <= 0 || colonPos >= strLen - 1)
      return -1;

   string hourStr = StringSubstr(cleanStr, 0, colonPos);
   string minStr = StringSubstr(cleanStr, colonPos + 1);

   if(StringLen(minStr) != 2)
      return -1;

   long hours = StringToInteger(hourStr);
   long minutes = StringToInteger(minStr);

   if(hours < 0 || hours > 23 || minutes < 0 || minutes > 59)
      return -1;

   return (int)(hours * 60 + minutes);
  }

//+------------------------------------------------------------------+
//| Helper: Midnight wrap check                                      |
//+------------------------------------------------------------------+
bool IsWrappedSession(int startMin, int endMin)
  {
   return startMin > endMin;
  }

//+------------------------------------------------------------------+
//| Update timezone offsets                                          |
//+------------------------------------------------------------------+
void UpdateTimezoneOffsets()
  {
   datetime utcNow = TimeGMT();
   datetime serverNow = TimeTradeServer();
   datetime pcNow = TimeLocal();

   serverToUtcOffset = (int)(utcNow - serverNow);
   pcToUtcOffset = (int)(utcNow - pcNow);

   serverToUtcOffset = NormalizeOffset(serverToUtcOffset);
   pcToUtcOffset = NormalizeOffset(pcToUtcOffset);
  }

//+------------------------------------------------------------------+
//| Normalize timezone offset                                        |
//+------------------------------------------------------------------+
int NormalizeOffset(int rawOffset)
  {
   int hours = rawOffset / 3600;
   int minutes = (rawOffset % 3600) / 60;

   if(hours > 14)
     {
      hours = hours - 24;
     }
   else
      if(hours < -14)
        {
         hours = hours + 24;
        }

   return hours * 3600 + minutes * 60;
  }

//+------------------------------------------------------------------+
//| Convert to reference time                                        |
//+------------------------------------------------------------------+
datetime ConvertToReferenceTime(datetime chartTime)
  {
   if(SessionTimeMode == "Broker/Server Time")
     {
      return chartTime;
     }
   else
      if(SessionTimeMode == "UTC")
        {
         return chartTime + serverToUtcOffset;
        }
      else
         if(SessionTimeMode == "PC Local Time")
           {
            datetime utcTime = chartTime + serverToUtcOffset;
            return utcTime - pcToUtcOffset;
           }
         else
           {
            return chartTime;
           }
  }

//+------------------------------------------------------------------+
//| Apply manual DST shift                                           |
//+------------------------------------------------------------------+
datetime ApplyManualShift(datetime refTime)
  {
   if(ManualDSTShiftHours == 0)
      return refTime;

   return refTime + ManualDSTShiftHours * 3600;
  }

//+------------------------------------------------------------------+
//| Get time of day in minutes                                       |
//+------------------------------------------------------------------+
int GetTimeOfDayMinutes(datetime dt)
  {
   MqlDateTime mdt;
   TimeToStruct(dt, mdt);
   return mdt.hour * 60 + mdt.min;
  }

//+------------------------------------------------------------------+
//| Initialize session times                                         |
//+------------------------------------------------------------------+
void InitializeSessions()
  {
   sessionTimes[0][0] = TimeStringToMinutes(AsiaStart);
   sessionTimes[0][1] = TimeStringToMinutes(AsiaEnd);

   sessionTimes[1][0] = TimeStringToMinutes(LondonOpenStart);
   sessionTimes[1][1] = TimeStringToMinutes(LondonOpenEnd);

   sessionTimes[2][0] = TimeStringToMinutes(OverlapStart);
   sessionTimes[2][1] = TimeStringToMinutes(OverlapEnd);

   sessionTimes[3][0] = TimeStringToMinutes(NYCloseStart);
   sessionTimes[3][1] = TimeStringToMinutes(NYCloseEnd);

   sessionTimes[4][0] = TimeStringToMinutes(PacificStart);
   sessionTimes[4][1] = TimeStringToMinutes(PacificEnd);

   for(int i = 0; i < 5; i++)
     {
      sessionValid[i] = (sessionTimes[i][0] >= 0 && sessionTimes[i][1] >= 0);
     }
  }

//+------------------------------------------------------------------+
//| Check if in session                                              |
//+------------------------------------------------------------------+
bool IsTimeInSession(int todMin, int sessionIdx)
  {
   if(!sessionValid[sessionIdx])
      return false;

   int start = sessionTimes[sessionIdx][0];
   int end = sessionTimes[sessionIdx][1];

   if(IsWrappedSession(start, end))
     {
      return (todMin >= start) || (todMin < end);
     }
   else
     {
      return (todMin >= start) && (todMin < end);
     }
  }

//+------------------------------------------------------------------+
//| Calculate smooth transition                                       |
//+------------------------------------------------------------------+
double CalculateTransition(int todMin, int startMin, int endMin, bool rising)
  {
   double progress = 0.0;

   if(IsWrappedSession(startMin, endMin))
     {
      if(todMin >= startMin)
         progress = (double)(todMin - startMin) / (double)((1440 - startMin) + endMin);
      else
         if(todMin < endMin)
            progress = (double)(todMin + 1440 - startMin) / (double)((1440 - startMin) + endMin);
         else
            progress = rising ? 0.0 : 1.0;
     }
   else
     {
      progress = (double)(todMin - startMin) / (double)(endMin - startMin);
     }

   progress = MathMin(1.0, MathMax(0.0, progress));
   progress = progress * progress * (3.0 - 2.0 * progress);

   return rising ? progress : 1.0 - progress;
  }



//+------------------------------------------------------------------+
//| Extract Color Components                                         |
//+------------------------------------------------------------------+
uchar GetRed(color clr)   { return (uchar)clr & 0xFF; }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uchar GetGreen(color clr) { return (uchar)(clr >> 8) & 0xFF; }
uchar GetBlue(color clr)  { return (uchar)(clr >> 16) & 0xFF; }

//+------------------------------------------------------------------+
//| Interpolate between two colors                                   |
//+------------------------------------------------------------------+
color InterpolateColor(color c1, color c2, double factor)
  {
   factor = MathMax(0.0, MathMin(1.0, factor));

   uchar r1 = GetRed(c1);
   uchar g1 = GetGreen(c1);
   uchar b1 = GetBlue(c1);

   uchar r2 = GetRed(c2);
   uchar g2 = GetGreen(c2);
   uchar b2 = GetBlue(c2);

   uchar r = (uchar)(r1 + (r2 - r1) * factor);
   uchar g = (uchar)(g1 + (g2 - g1) * factor);
   uchar b = (uchar)(b1 + (b2 - b1) * factor);

   return (color)(b << 16 | g << 8 | r);
  }

//+------------------------------------------------------------------+
//| Get Gradient Color based on Session Phase                        |
//+------------------------------------------------------------------+
color GetGradientColor(datetime chartTime)
  {
   if(!EnableGradient)
      return PacificColor;

   datetime refTime = ConvertToReferenceTime(chartTime);
   refTime = ApplyManualShift(refTime);
   int todMin = GetTimeOfDayMinutes(refTime);

// --- 1. PACIFIC (The Void / Reset) ---
// 21:00 - 00:00
   if(IsTimeInSession(todMin, 4))
     {
      return PacificColor;
     }

// --- 2. ASIA (The Range Box) ---
// 00:00 - 07:00
   if(IsTimeInSession(todMin, 0))
     {
      // Check for overlap with Pacific (early morning 00:00-06:00?)
      // We keep Asia solid to clearly define the "Range"
      return AsiaColor;
     }

// --- 3. LONDON PHASE (Activity) ---
// London Open: 07:00 - 09:00 (Transition Phase)
   if(IsTimeInSession(todMin, 1))
     {
      // Ramp up from Asia -> London
      double progress = CalculateTransition(todMin, sessionTimes[1][0], sessionTimes[1][1], true);
      return InterpolateColor(AsiaColor, LondonColor, progress);
     }

// London Proper (Gap): 09:00 - 12:00 (Solid Phase)
   int gapStart = sessionTimes[1][1];
   int gapEnd = sessionTimes[2][0];
   if(todMin >= gapStart && todMin < gapEnd)
     {
      return LondonColor; // Solid Grey/Activity Color
     }

// --- 4. NY / OVERLAP PHASE (Volatility) ---
// Overlap: 12:00 - 16:00
   if(IsTimeInSession(todMin, 2))
     {
      // 12:00 - 13:00: Transition London -> NY (Warning phase)
      int overlapStart = sessionTimes[2][0];
      int transitionEnd = overlapStart + 60; // 1 Hour transition

      if(todMin < transitionEnd)
        {
         double p = (double)(todMin - overlapStart) / 60.0;
         return InterpolateColor(LondonColor, NYColor, p);
        }

      // 13:00 - 16:00: Solid Peak Volatility
      return NYColor;
     }

// --- 5. NY CLOSE (Fade Out) ---
// 16:00 - 21:00
   if(IsTimeInSession(todMin, 3))
     {
      double progress = CalculateTransition(todMin, sessionTimes[3][0], sessionTimes[3][1], false);
      // Fade from NY -> Pacific
      return InterpolateColor(PacificColor, NYColor, progress);
     }

   return PacificColor;
  }

//+------------------------------------------------------------------+
//| Parse sunray times                                               |
//+------------------------------------------------------------------+
void ParseSunrayTimes()
  {
   sunrayCount = 0;
   if(StringLen(SunrayTimes) == 0)
      return;

   string workString = SunrayTimes;
   StringTrimLeft(workString);
   StringTrimRight(workString);
   int maxTimes = 50;
   datetime tempTimes[50];
   int count = 0;

   while(StringLen(workString) > 0 && count < maxTimes)
     {
      int semicolonPos = StringFind(workString, ";");
      string currentTimeStr;

      if(semicolonPos >= 0)
        {
         currentTimeStr = StringSubstr(workString, 0, semicolonPos);
         workString = StringSubstr(workString, semicolonPos + 1);
        }
      else
        {
         currentTimeStr = workString;
         workString = "";
        }

      StringTrimLeft(currentTimeStr);
      StringTrimRight(currentTimeStr);
      if(StringLen(currentTimeStr) == 0)
         continue;

      datetime parsedTime = 0;
      int spacePos = StringFind(currentTimeStr, " ");
      if(spacePos > 0)
        {
         parsedTime = StringToTime(currentTimeStr);
        }
      else
        {
         MqlDateTime mdt;
         TimeToStruct(TimeCurrent(), mdt);

         int colonPos = StringFind(currentTimeStr, ":");
         if(colonPos > 0)
           {
            string hourPart = StringSubstr(currentTimeStr, 0, colonPos);
            string minPart = StringSubstr(currentTimeStr, colonPos + 1);

            if(StringLen(minPart) == 2)
              {
               long hourVal = StringToInteger(hourPart);
               long minVal = StringToInteger(minPart);

               if(hourVal >= 0 && hourVal <= 23 && minVal >= 0 && minVal <= 59)
                 {
                  mdt.hour = (int)hourVal;
                  mdt.min = (int)minVal;
                  mdt.sec = 0;
                  parsedTime = StructToTime(mdt);
                 }
              }
           }
        }

      if(parsedTime > 0)
        {
         tempTimes[count] = parsedTime;
         count++;
        }
     }

   if(count > 0)
     {
      ArrayResize(sunrayTimes, count);
      for(int i = 0; i < count; i++)
        {
         sunrayTimes[i] = tempTimes[i];
        }
      sunrayCount = count;
     }
  }

//+------------------------------------------------------------------+
//| Get session name                                                 |
//+------------------------------------------------------------------+
string GetSessionName(datetime chartTime)
  {
   datetime refTime = ConvertToReferenceTime(chartTime);
   refTime = ApplyManualShift(refTime);
   int todMin = GetTimeOfDayMinutes(refTime);

// Priority order matters
   if(IsTimeInSession(todMin, 2))
      return "London/NY Overlap";

   if(IsTimeInSession(todMin, 1))
      return "London Open";

// Check Gap (London Session)
   int gapStart = sessionTimes[1][1];
   int gapEnd = sessionTimes[2][0];
   if(todMin >= gapStart && todMin < gapEnd)
      return "London Session";

   if(IsTimeInSession(todMin, 3))
      return "NY Session"; // Renamed from NY Close

// Complex Overlap Checks for Asia/Pacific
   bool inAsia = IsTimeInSession(todMin, 0);
   bool inPacific = IsTimeInSession(todMin, 4);

   if(inAsia && inPacific)
      return "Asia/Pacific Overlap";
   if(inAsia)
      return "Asia Session";
   if(inPacific)
      return "Pacific Session";

   return "";
  }

//+------------------------------------------------------------------+
//| Get Event Label (Events within this bar)                         |
//+------------------------------------------------------------------+
string GetEventLabel(datetime barStart, datetime barEnd)
  {
   string label = "";

// Convert bar times to Minute-of-Day (0-1439)
// We need to handle day wrapping for the check
   datetime refStart = ConvertToReferenceTime(barStart);
   refStart = ApplyManualShift(refStart);

   int startMin = GetTimeOfDayMinutes(refStart);

// Calculate end minute. If it wraps over midnight, we handle it.
   int duration = (int)(barEnd - barStart) / 60;

// 1. Asia Open (00:00)
   if(IsTimeInWindow(sessionTimes[0][0], startMin, duration))
      AddLabel(label, "Asia Open");

// 2. Pacific Close (06:00)
   if(IsTimeInWindow(sessionTimes[4][1], startMin, duration))
      AddLabel(label, "Pacific Close");

// 3. Asia Close / London Open (Usually 07:00)
   bool asiaClose = IsTimeInWindow(sessionTimes[0][1], startMin, duration);
   bool londonOpen = IsTimeInWindow(sessionTimes[1][0], startMin, duration);

   if(asiaClose && londonOpen)
      AddLabel(label, "London Open | Asia Close");
   else
     {
      if(asiaClose)
         AddLabel(label, "Asia Close");
      if(londonOpen)
         AddLabel(label, "London Open");
     }

// 4. NY Open (Overlap Start - 12:00)
   if(IsTimeInWindow(sessionTimes[2][0], startMin, duration))
      AddLabel(label, "NY Open");

// 5. London Close (Overlap End - 16:00)
   if(IsTimeInWindow(sessionTimes[2][1], startMin, duration))
      AddLabel(label, "London Close");

// 6. NY Close / Pacific Open (21:00)
   bool nyClose = IsTimeInWindow(sessionTimes[3][1], startMin, duration);
   bool pacificOpen = IsTimeInWindow(sessionTimes[4][0], startMin, duration);

   if(nyClose && pacificOpen)
      AddLabel(label, "NY Close | Pacific Open");
   else
     {
      if(nyClose)
         AddLabel(label, "NY Close");
      if(pacificOpen)
         AddLabel(label, "Pacific Open");
     }

   return label;
  }

// Helper to append text
void AddLabel(string &lbl, string newTxt)
  {
   if(StringLen(lbl) > 0)
      lbl += " | ";
   lbl += newTxt;
  }

// Helper to check if a specific minute target is inside the bar's duration
bool IsTimeInWindow(int targetMin, int startMin, int duration)
  {
   if(duration <= 0)
      return false;

   int endMin = startMin + duration;

// Simple case: no midnight wrap in bar
   if(endMin < 1440)
     {
      return (targetMin >= startMin && targetMin < endMin);
     }
   else
     {
      // Bar wraps midnight (e.g. 23:50 to 00:10)
      // Check first part (start to 1439)
      if(targetMin >= startMin)
         return true;
      // Check second part (0 to remainder)
      if(targetMin < (endMin - 1440))
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Helper: Get Vertical Lane Index (Prevent Overlap)                |
//+------------------------------------------------------------------+
int GetLaneIndex(int hour)
  {
// Manual distribution to ensure critical adjacent/close events don't clash
// Cycle: 0 -> 1 -> 2
   switch(hour)
     {
      case 0:
         return 0; // Asia Open
      case 6:
         return 1; // Pacific Close
      case 7:
         return 2; // London Open
      case 12:
         return 0; // NY Open
      case 16:
         return 1; // London Close
      case 21:
         return 2; // NY Close
      default:
         return (hour % 3); // Fallback
     }
  }

//+------------------------------------------------------------------+
//| Manage objects (Smart Update)                                    |
//+------------------------------------------------------------------+
void UpdateVisuals(const datetime &time[], const int rates_total)
  {
   if(!EnableGradient)
      return;

// --- 1. Determine Visible Range + Buffer ---
   int visibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   if(visibleBars <= 0)
      visibleBars = 100;

   int firstVisibleBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   double chartMin = ChartGetDouble(0, CHART_PRICE_MIN);
   double chartMax = ChartGetDouble(0, CHART_PRICE_MAX);

   int startIdx = 0;
   int endIdx = rates_total - 1;

   if(firstVisibleBar >= 0)
     {
      int leftMostStandardIndex = rates_total - 1 - firstVisibleBar;
      int buffer = 100;
      startIdx = leftMostStandardIndex - buffer;
      endIdx = leftMostStandardIndex + visibleBars + buffer;
     }

   startIdx = MathMax(0, startIdx);
   endIdx = MathMin(rates_total - 1, endIdx);

// --- 2. Iteration & Drawing ---
   for(int i = startIdx; i <= endIdx; i++)
     {
      datetime barTime = time[i];
      if(barTime == 0)
         continue;

      // Calculate Bar End Time
      datetime barEndTime;
      if(i < rates_total - 1)
         barEndTime = time[i + 1];
      else
         barEndTime = barTime + PeriodSeconds();

      // --- A. Gradient Background (State Based) ---
      string currentSession = GetSessionName(barTime);
      // We still use GetSessionName for COLOR determination logic (State)

      string gradObjName = indicatorPrefix + "gradient_" + (string)barTime;

      color barColor;
      // Logic for background color
      barColor = GetGradientColor(barTime);

      if(ObjectFind(0, gradObjName) < 0)
        {
         ObjectCreate(0, gradObjName, OBJ_RECTANGLE, 0, barTime, chartMax, barEndTime, chartMin);
         ObjectSetInteger(0, gradObjName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, gradObjName, OBJPROP_WIDTH, 0);
         ObjectSetInteger(0, gradObjName, OBJPROP_FILL, true);
         ObjectSetInteger(0, gradObjName, OBJPROP_BACK, true);
         ObjectSetInteger(0, gradObjName, OBJPROP_SELECTABLE, false);
        }

      color finalColor = (color)((MaxOpacity << 24) | (barColor & 0x00FFFFFF));
      ObjectSetInteger(0, gradObjName, OBJPROP_COLOR, finalColor);
      ObjectMove(0, gradObjName, 0, barTime, chartMax);
      ObjectMove(0, gradObjName, 1, barEndTime, chartMin);


      // --- B. Event Labels & Separators (Event Based) ---
      string eventLabel = GetEventLabel(barTime, barEndTime);

      string lineObjName = indicatorPrefix + "sep_" + (string)barTime;
      string labelObjName = indicatorPrefix + "label_" + (string)barTime;

      if(StringLen(eventLabel) > 0)
        {
         // 1. Vertical Separator Line
         if(ShowSessionLines)
           {
            if(ObjectFind(0, lineObjName) < 0)
              {
               ObjectCreate(0, lineObjName, OBJ_VLINE, 0, barTime, 0);
               ObjectSetInteger(0, lineObjName, OBJPROP_COLOR, SessionLineColor);
               ObjectSetInteger(0, lineObjName, OBJPROP_STYLE, SessionLineStyle);
               ObjectSetInteger(0, lineObjName, OBJPROP_WIDTH, SessionLineWidth);
               ObjectSetInteger(0, lineObjName, OBJPROP_BACK, true);
               ObjectSetInteger(0, lineObjName, OBJPROP_SELECTABLE, false);
              }
            ObjectMove(0, lineObjName, 0, barTime, 0);
           }

         // 2. Labels (Time/Price Anchored - No Jitter + Badge Background)
         // Robust Lane Logic with Manual Map
         datetime refTime = ConvertToReferenceTime(barTime);
         refTime = ApplyManualShift(refTime);
         MqlDateTime mdt;
         TimeToStruct(refTime, mdt);

         int laneIdx = GetLaneIndex(mdt.hour);
         double yOffsetPct = 0.02 + (laneIdx * 0.04); // Staggered heights: 2%, 6%, 10%
         double labelPrice = chartMax - (chartMax - chartMin) * yOffsetPct;

         // --- Background Badge (Solid Blocks) ---
         string labelBgObjName = indicatorPrefix + "label_bg_" + (string)barTime;

         // Tighter width calculation (Adjusted):
         // Increased multiplier to 0.7 and added +2 padding to ensure full coverage for all label lengths.
         int strLen = StringLen(eventLabel);
         int blockCount = (int)(strLen * 0.70) + 2;
         if(blockCount < 1)
            blockCount = 1;

         string blockStr = "";
         for(int k=0; k < blockCount; k++)
            blockStr += "█";
         // Removed extra padding to fit tighter

         if(ObjectFind(0, labelBgObjName) < 0)
           {
            ObjectCreate(0, labelBgObjName, OBJ_TEXT, 0, barTime, labelPrice);
            ObjectSetInteger(0, labelBgObjName, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, labelBgObjName, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, labelBgObjName, OBJPROP_COLOR, clrBlack);
            ObjectSetInteger(0, labelBgObjName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            ObjectSetInteger(0, labelBgObjName, OBJPROP_BACK, false);
            ObjectSetInteger(0, labelBgObjName, OBJPROP_SELECTABLE, false);
           }
         ObjectSetString(0, labelBgObjName, OBJPROP_TEXT, blockStr);
         ObjectMove(0, labelBgObjName, 0, barTime, labelPrice);

         // --- Main Text ---
         if(ObjectFind(0, labelObjName) < 0)
           {
            ObjectCreate(0, labelObjName, OBJ_TEXT, 0, barTime, labelPrice);
            ObjectSetInteger(0, labelObjName, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, labelObjName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, labelObjName, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, labelObjName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            ObjectSetInteger(0, labelObjName, OBJPROP_BACK, false);
            ObjectSetInteger(0, labelObjName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, labelObjName, OBJPROP_ZORDER, 10); // Top
           }

         ObjectSetString(0, labelObjName, OBJPROP_TEXT, " " + eventLabel); // Minimal leading space
         ObjectMove(0, labelObjName, 0, barTime, labelPrice);
        }
      else
        {
         // Cleanup
         if(ObjectFind(0, lineObjName) >= 0)
            ObjectDelete(0, lineObjName);
         if(ObjectFind(0, labelObjName) >= 0)
            ObjectDelete(0, labelObjName);
         string bgName = indicatorPrefix + "label_bg_" + (string)barTime;
         if(ObjectFind(0, bgName) >= 0)
            ObjectDelete(0, bgName);
        }
     }
  }

//+------------------------------------------------------------------+
//| Create gradient objects (Deprecated wrapper)                     |
//+------------------------------------------------------------------+
void CreateGradientObjects(const datetime &time[], const int rates_total)
  {
   UpdateVisuals(time, rates_total);
  }

//+------------------------------------------------------------------+
//| Create sunray objects                                            |
//+------------------------------------------------------------------+
void CreateSunrayObjects()
  {
   if(!EnableSunrays || sunrayCount == 0)
      return;

   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, indicatorPrefix + "sunray_") == 0)
        {
         ObjectDelete(0, objName);
        }
     }

   for(int i = 0; i < sunrayCount; i++)
     {
      datetime eventTime = sunrayTimes[i];
      if(eventTime == 0)
         continue;

      datetime chartTime = eventTime;
      if(SessionTimeMode == "UTC")
        {
         chartTime = eventTime - serverToUtcOffset;
        }
      else
         if(SessionTimeMode == "PC Local Time")
           {
            datetime utcTime = eventTime + pcToUtcOffset;
            chartTime = utcTime - serverToUtcOffset;
           }

      chartTime -= ManualDSTShiftHours * 3600;

      string objName = indicatorPrefix + "sunray_" + (string)chartTime;

      datetime startTime = chartTime - (SunrayWidthMinutes * 60);
      datetime endTime = chartTime + (SunrayWidthMinutes * 60);

      double chartMin = ChartGetDouble(0, CHART_PRICE_MIN);
      double chartMax = ChartGetDouble(0, CHART_PRICE_MAX);

      ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, startTime, chartMax, endTime, chartMin);

      // Apply sunray opacity using alpha channel
      color finalSunrayColor = (color)((SunrayOpacity << 24) | (SunrayColor & 0x00FFFFFF));
      ObjectSetInteger(0, objName, OBJPROP_COLOR, finalSunrayColor);

      ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, objName, OBJPROP_FILL, true);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
     }
  }

//+------------------------------------------------------------------+
//| Delete all indicator objects                                      |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, indicatorPrefix) == 0)
         ObjectDelete(0, objName);
     }
  }

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, dummyBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   UpdateTimezoneOffsets();
   InitializeSessions();
   ParseSunrayTimes();
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();

// Reset cache
   lastVisibleBars = -1;
   lastFirstVisibleBar = -1;
   lastChartMin = 0;
   lastChartMax = 0;
   hasCachedData = false;
   cachedRatesTotal = 0;
   ArrayResize(cachedTime, 0);
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
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
   if(TimeCurrent() - lastUpdateTime > 3600)
     {
      UpdateTimezoneOffsets();
      lastUpdateTime = TimeCurrent();
     }

// Cache the time array and rates_total for use in OnChartEvent
   if(rates_total > 0)
     {
      cachedRatesTotal = rates_total;
      ArrayResize(cachedTime, rates_total);
      for(int i = 0; i < rates_total; i++)
         cachedTime[i] = time[i];
      hasCachedData = true;
     }

   CreateGradientObjects(time, rates_total);

   if(EnableSunrays)
      CreateSunrayObjects();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE || id == CHARTEVENT_CLICK)
     {
      // Only recreate objects if we have cached data from OnCalculate
      if(hasCachedData && cachedRatesTotal > 0)
        {
         CreateGradientObjects(cachedTime, cachedRatesTotal);
         if(EnableSunrays)
            CreateSunrayObjects();
        }
     }
  }
//+------------------------------------------------------------------+
