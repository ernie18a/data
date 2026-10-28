//+------------------------------------------------------------------+
//|                                           Fair_Value_Gap_FVG.mq5 |
//|                                     Forexobroker - Dominic Walsh |
//|                                     https://www.forexobroker.com |
//+------------------------------------------------------------------+
#property copyright "Forexobroker - Dominic Walsh"
#property link      "https://www.forexobroker.com"
#property version   "1.00"
#property indicator_chart_window
#property description "Detects Fair Value Gaps (FVG) - a core Smart Money / ICT concept."
#property description "Shows unfilled imbalances as zones, tracks gap fill status."
#property description ""
#property description "For professional multi-symbol pattern scanners, visit MQL5 Market"
#property description "and search for Dashboard indicators by Dominic Walsh."
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_FILL_MODE
  {
   FILL_REMOVE = 0,  // Remove filled gaps
   FILL_FADE   = 1,  // Fade filled gaps (reduce opacity)
   FILL_KEEP   = 2   // Keep filled gaps unchanged
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group           "=== FVG Detection ==="
input bool            InpShowBullish     = true;       // Show Bullish FVG
input bool            InpShowBearish     = true;       // Show Bearish FVG
input int             InpMinGapPoints    = 10;         // Minimum Gap Size (points)
input int             InpLookback        = 500;        // Maximum Lookback Bars

input group           "=== Display Settings ==="
input color           InpBullishColor    = clrDodgerBlue;  // Bullish FVG Color
input color           InpBearishColor    = clrTomato;      // Bearish FVG Color
input ENUM_FILL_MODE  InpFillMode        = FILL_FADE;      // Filled Gap Handling
input int             InpBoxOpacity      = 50;             // Box Opacity (0-255)
input bool            InpShowLabel       = true;            // Show Gap Size Label
input int             InpMaxFVGs         = 50;              // Max FVGs to Display

input group           "=== Alerts ==="
input bool            InpAlertNewFVG     = false;      // Alert on New FVG
input bool            InpAlertFill       = false;      // Alert on FVG Fill
input bool            InpPushNotify      = false;      // Push Notification
input bool            InpEmailAlert      = false;      // Email Alert

//+------------------------------------------------------------------+
//| FVG Data Structure                                                |
//+------------------------------------------------------------------+
struct FVGData
  {
   double            upper;         // Upper boundary of the gap
   double            lower;         // Lower boundary of the gap
   datetime          timeStart;     // Start time (candle that created the gap)
   datetime          timeEnd;       // End time (extended right)
   int               barIndex;      // Bar index when detected
   bool              isBullish;     // true = bullish, false = bearish
   bool              isFilled;      // Whether price has filled this gap
   string            rectName;      // Object name for the rectangle
   string            labelName;     // Object name for the label
  };

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
FVGData  g_fvgArray[];        // Dynamic array of all tracked FVGs
int      g_fvgCount    = 0;   // Current count of FVGs
int      g_prevBars    = 0;   // Previous bar count for new-bar detection
string   g_prefix      = "FVG_";  // Object name prefix
int      g_opacity;           // Clamped opacity value
double   g_minGapSize;        // Minimum gap size in price terms

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Validate and clamp opacity
   g_opacity = MathMax(0, MathMin(255, InpBoxOpacity));

   // Convert minimum gap size from points to price
   g_minGapSize = InpMinGapPoints * _Point;

   // Clean slate
   ObjectsDeleteAll(0, g_prefix);
   ArrayFree(g_fvgArray);
   g_fvgCount  = 0;
   g_prevBars  = 0;

   Print("Fair Value Gap FVG Indicator initialized | Min gap: ",
         InpMinGapPoints, " pts | Lookback: ", InpLookback, " bars");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Remove all indicator objects from the chart
   ObjectsDeleteAll(0, g_prefix);
   Comment("");
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   // Need at least 3 bars for FVG detection
   if(rates_total < 3)
      return(rates_total);

   // MQL5 arrays are left-to-right by default (index 0 = oldest)
   // We keep default indexing — newest bar is at index [rates_total - 1]

   // Determine the scanning range
   int startBar, endBar;

   if(prev_calculated == 0 || g_prevBars == 0)
     {
      // Full recalculation — clear old objects and data
      ObjectsDeleteAll(0, g_prefix);
      ArrayFree(g_fvgArray);
      g_fvgCount = 0;

      // Start from lookback limit (need i-2 to exist, so minimum start is index 2)
      startBar = MathMax(2, rates_total - InpLookback);
      endBar   = rates_total - 1;  // Include the latest bar
     }
   else
     {
      // Incremental — only scan new bars
      // We scan from the last calculated position minus 2 (need 3-bar pattern)
      startBar = MathMax(2, prev_calculated - 2);
      endBar   = rates_total - 1;
     }

   //--- Detect new FVGs on confirmed bars only (exclude bar 0 = latest forming bar)
   //    In left-to-right indexing, bar at index i is confirmed if i < rates_total - 1
   //    The pattern uses bars i, i-1, i-2 where i is the newest of the three
   for(int i = startBar; i < rates_total - 1; i++)
     {
      // Skip bars we already processed (avoid duplicate FVGs)
      if(prev_calculated > 0 && i < prev_calculated - 2)
         continue;

      //--- Bullish FVG: low[i] > high[i-2]
      //    Gap exists between the high of 2 bars ago and the low of current bar
      //    The middle bar (i-1) is the impulse candle
      if(InpShowBullish)
        {
         if(low[i] > high[i - 2])
           {
            double gapSize = low[i] - high[i - 2];
            if(gapSize >= g_minGapSize)
              {
               AddFVG(high[i - 2], low[i], time[i - 1], time[i], i, true);
              }
           }
        }

      //--- Bearish FVG: high[i] < low[i-2]
      //    Gap exists between the low of 2 bars ago and the high of current bar
      if(InpShowBearish)
        {
         if(high[i] < low[i - 2])
           {
            double gapSize = low[i - 2] - high[i];
            if(gapSize >= g_minGapSize)
              {
               AddFVG(high[i], low[i - 2], time[i - 1], time[i], i, false);
              }
           }
        }
     }

   //--- Update fill status for all active FVGs using the latest price data
   UpdateFillStatus(high, low, time, rates_total);

   //--- Extend unfilled FVG rectangles to the right edge of the chart
   ExtendFVGRectangles(time, rates_total);

   g_prevBars = rates_total;
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Add a new FVG to the tracking array and draw it on chart          |
//+------------------------------------------------------------------+
void AddFVG(double lowerPrice, double upperPrice, datetime tStart, datetime tEnd,
            int barIdx, bool bullish)
  {
   //--- Enforce max FVG limit — remove the oldest if at capacity
   if(g_fvgCount >= InpMaxFVGs)
      RemoveOldestFVG();

   //--- Resize the array
   g_fvgCount++;
   ArrayResize(g_fvgArray, g_fvgCount, 20);

   int idx = g_fvgCount - 1;

   //--- Populate the FVG data
   g_fvgArray[idx].upper     = upperPrice;
   g_fvgArray[idx].lower     = lowerPrice;
   g_fvgArray[idx].timeStart = tStart;
   g_fvgArray[idx].timeEnd   = tEnd;
   g_fvgArray[idx].barIndex  = barIdx;
   g_fvgArray[idx].isBullish = bullish;
   g_fvgArray[idx].isFilled  = false;

   //--- Create unique object names
   string typeStr = bullish ? "Bull" : "Bear";
   string nameBase = g_prefix + typeStr + "_" + IntegerToString(barIdx) + "_" +
                     TimeToString(tStart, TIME_DATE | TIME_MINUTES);

   g_fvgArray[idx].rectName  = nameBase + "_Rect";
   g_fvgArray[idx].labelName = nameBase + "_Label";

   //--- Draw the rectangle
   color fillColor = bullish ? InpBullishColor : InpBearishColor;
   DrawFVGRectangle(g_fvgArray[idx].rectName, tStart, lowerPrice, tEnd, upperPrice,
                    fillColor, g_opacity);

   //--- Draw the gap size label
   if(InpShowLabel)
     {
      double gapPips = (upperPrice - lowerPrice) / _Point;
      string labelText = typeStr + " FVG " + DoubleToString(gapPips, 0) + " pts";
      double labelPrice = (upperPrice + lowerPrice) / 2.0;
      DrawFVGLabel(g_fvgArray[idx].labelName, tStart, labelPrice, labelText, fillColor);
     }

   //--- Fire alerts for new FVG
   if(InpAlertNewFVG || InpPushNotify || InpEmailAlert)
     {
      double gapPips = (upperPrice - lowerPrice) / _Point;
      string msg = _Symbol + " " + EnumToString((ENUM_TIMEFRAMES)Period()) + ": New " +
                   typeStr + " FVG detected | Size: " + DoubleToString(gapPips, 0) + " pts" +
                   " | Zone: " + DoubleToString(lowerPrice, _Digits) + " - " +
                   DoubleToString(upperPrice, _Digits);

      if(InpAlertNewFVG)
         Alert(msg);
      if(InpPushNotify)
         SendNotification(msg);
      if(InpEmailAlert)
         SendMail("New FVG - " + _Symbol, msg);
     }
  }

//+------------------------------------------------------------------+
//| Remove the oldest FVG from the array and chart                    |
//+------------------------------------------------------------------+
void RemoveOldestFVG()
  {
   if(g_fvgCount <= 0)
      return;

   // Delete chart objects for the oldest entry (index 0)
   ObjectDelete(0, g_fvgArray[0].rectName);
   ObjectDelete(0, g_fvgArray[0].labelName);

   // Shift array elements left by one
   for(int i = 0; i < g_fvgCount - 1; i++)
      g_fvgArray[i] = g_fvgArray[i + 1];

   g_fvgCount--;
   ArrayResize(g_fvgArray, g_fvgCount, 20);
  }

//+------------------------------------------------------------------+
//| Update fill status for all tracked FVGs                           |
//+------------------------------------------------------------------+
void UpdateFillStatus(const double &high[], const double &low[],
                      const datetime &time[], int rates_total)
  {
   if(rates_total < 1)
      return;

   // Check the latest bar's high/low against each unfilled FVG
   int latestBar = rates_total - 1;

   for(int i = g_fvgCount - 1; i >= 0; i--)
     {
      if(g_fvgArray[i].isFilled)
         continue;

      bool filled = false;

      //--- A bullish FVG is filled when price drops into the zone
      //    (the bar's low enters or goes below the FVG upper boundary)
      if(g_fvgArray[i].isBullish)
        {
         if(low[latestBar] <= g_fvgArray[i].upper)
            filled = true;
        }
      //--- A bearish FVG is filled when price rises into the zone
      //    (the bar's high enters or goes above the FVG lower boundary)
      else
        {
         if(high[latestBar] >= g_fvgArray[i].lower)
            filled = true;
        }

      if(filled)
        {
         g_fvgArray[i].isFilled = true;
         HandleFilledFVG(i);

         //--- Fire fill alerts
         if(InpAlertFill || InpPushNotify || InpEmailAlert)
           {
            string typeStr = g_fvgArray[i].isBullish ? "Bullish" : "Bearish";
            string msg = _Symbol + " " + EnumToString((ENUM_TIMEFRAMES)Period()) +
                         ": " + typeStr + " FVG FILLED | Zone: " +
                         DoubleToString(g_fvgArray[i].lower, _Digits) + " - " +
                         DoubleToString(g_fvgArray[i].upper, _Digits);

            if(InpAlertFill)
               Alert(msg);
            if(InpPushNotify)
               SendNotification(msg);
            if(InpEmailAlert)
               SendMail("FVG Filled - " + _Symbol, msg);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Handle a filled FVG based on user preference                      |
//+------------------------------------------------------------------+
void HandleFilledFVG(int idx)
  {
   switch(InpFillMode)
     {
      case FILL_REMOVE:
         // Delete the rectangle and label entirely
         ObjectDelete(0, g_fvgArray[idx].rectName);
         ObjectDelete(0, g_fvgArray[idx].labelName);
         break;

      case FILL_FADE:
        {
         // Reduce opacity to ~25% of original and change to gray tone
         int fadedOpacity = (int)MathMax(10, g_opacity * 0.25);
         color fadedColor = clrGray;

         ObjectSetInteger(0, g_fvgArray[idx].rectName, OBJPROP_COLOR, fadedColor);
         ObjectSetInteger(0, g_fvgArray[idx].rectName, OBJPROP_BGCOLOR, fadedColor);

         // Apply faded fill using ARGB
         uchar alpha = (uchar)MathMax(0, MathMin(255, 255 - fadedOpacity));
         uint argbFill = ((uint)alpha << 24) | ColorToARGB(fadedColor, (uchar)fadedOpacity);
         ObjectSetInteger(0, g_fvgArray[idx].rectName, OBJPROP_FILL, true);

         // Update label text to show filled status
         if(InpShowLabel)
           {
            string currentText = ObjectGetString(0, g_fvgArray[idx].labelName, OBJPROP_TEXT);
            ObjectSetString(0, g_fvgArray[idx].labelName, OBJPROP_TEXT, currentText + " [FILLED]");
            ObjectSetInteger(0, g_fvgArray[idx].labelName, OBJPROP_COLOR, fadedColor);
           }
         break;
        }

      case FILL_KEEP:
         // Do nothing — keep as-is
         break;
     }
  }

//+------------------------------------------------------------------+
//| Extend unfilled FVG rectangles to the current bar                 |
//+------------------------------------------------------------------+
void ExtendFVGRectangles(const datetime &time[], int rates_total)
  {
   if(rates_total < 1)
      return;

   datetime rightEdge = time[rates_total - 1];

   for(int i = 0; i < g_fvgCount; i++)
     {
      // Only extend unfilled gaps (or all if FILL_KEEP mode)
      if(!g_fvgArray[i].isFilled || InpFillMode == FILL_KEEP || InpFillMode == FILL_FADE)
        {
         // Skip removed ones
         if(g_fvgArray[i].isFilled && InpFillMode == FILL_REMOVE)
            continue;

         ObjectSetInteger(0, g_fvgArray[i].rectName, OBJPROP_TIME, 1, rightEdge);
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw an FVG rectangle on the chart                                |
//+------------------------------------------------------------------+
void DrawFVGRectangle(string name, datetime t1, double p1,
                      datetime t2, double p2, color clr, int opacity)
  {
   // Delete if it already exists (safety)
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2))
     {
      Print("Failed to create rectangle: ", name, " Error: ", GetLastError());
      return;
     }

   // Set rectangle properties
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);        // Draw behind candles
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);  // Non-selectable
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);       // Hidden from objects list

   // Set fill color with opacity using ColorToARGB
   uchar alpha = (uchar)MathMax(0, MathMin(255, opacity));
   // Note: OBJ_RECTANGLE fill opacity is controlled via the color alpha channel
   // MQL5 rectangles with OBJPROP_FILL use OBJPROP_BGCOLOR for internal color
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
  }

//+------------------------------------------------------------------+
//| Draw a text label for the FVG zone                                |
//+------------------------------------------------------------------+
void DrawFVGLabel(string name, datetime t, double price, string text, color clr)
  {
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price))
     {
      Print("Failed to create label: ", name, " Error: ", GetLastError());
      return;
     }

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);  // Labels in front
  }

//+------------------------------------------------------------------+
//| ChartEvent handler for interactive features                       |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   // Reserved for future interactive features (click on FVG for details, etc.)
  }
//+------------------------------------------------------------------+
