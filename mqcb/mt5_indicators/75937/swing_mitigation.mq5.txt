//+------------------------------------------------------------------+
//|                               Swing_Mitigation_3Grid_Winrate.mq5 |
//|                                            Copyright 2026, israr |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com/en/users/searchmixed/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input Parameters
input group "--- Swing Calculation ---"
input int      InpLeftRightBars =50;        // Half-Window (8 Left + 1 Center + 8 Right = 17 Candles)
input int      InpMaxBars       = 1500;     // Max Bars to Calculate (Big Picture)

input group "--- Horizontal Mitigation Lines ---"
input color    InpHighColor     = clrRed;      // Swing High Line Color
input color    InpLowColor      = clrLimeGreen;// Swing Low Line Color
input ENUM_LINE_STYLE InpStyle  = STYLE_SOLID; // Line Style
input int      InpLineWidth     = 1;           // Line Width

input group "--- Mitigation Wingdings Arrows ---"
input bool     InpShowArrows    = true;        // Draw Buy/Sell Mitigation Arrows
input color    InpBuyArrowClr   = clrDeepPink; // Buy Arrow Color (Wingdings 233)
input color    InpSellArrowClr  = clrRed;      // Sell Arrow Color (Wingdings 234)
input int      InpArrowSize     = 2;           // Arrow Size (1 to 5)

input group "--- 3-Grid-Box SL Settings ---"
input bool     InpShowSLBox       = true;           // Draw SL Rectangle Box
input int      InpGridBoxMultiplier = 3;            // Height in Grid Boxes (Default = 3 Grid Boxes)
input int      InpPixelsPerGrid   = 50;             // Pixels per 1 Grid Box (MT5 Default = 50px)
input color    InpSLBoxColor      = C'240,230,210'; // SL Box Fill Color (Beige/Tan)
input color    InpSLBoxBorderClr  = clrTan;         // SL Box Border Color
input int      InpSLBoxWidthBars  = 3;              // SL Box Width in Bars

input group "--- Signal Winrate Scanner Settings ---"
input double   InpRiskReward    = 1.5;         // Risk : Reward Ratio (1.5 = 1:1.5 TP vs 3-Grid SL)

input group "--- Dashboard Panel HUD ---"
input bool     InpShowDashboard = true;        // Show Winrate Dashboard Panel
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel Position

input group "--- Wave Background Highlight ---"
input bool     InpShowBackground = true;       // Show Background Wave Color
input color    InpBullBgColor    = C'10,35,15';  // Bullish Wave Color (Dark Soft Green)
input color    InpBearBgColor    = C'40,12,12';  // Bearish Wave Color (Dark Soft Red)

input group "--- Wave Structure Lines (ZigZag) ---"
input bool     InpShowStructure  = true;           // Draw Structure Wave Line
input color    InpStructureColor = clrDeepSkyBlue; // Structure Line Color
input int      InpStructureWidth = 3;              // Structure Line Thickness

//--- Global Variables
string OBJ_PREFIX_LINE  = "SML_L_";
string OBJ_PREFIX_BG    = "SML_BG_";
string OBJ_PREFIX_ZZ    = "SML_ZZ_";
string OBJ_PREFIX_ARR   = "SML_ARR_";
string OBJ_PREFIX_SLBOX = "SML_SLBOX_";
string OBJ_PREFIX_PNL   = "SML_PNL_";

struct SwingNode
{
   datetime time;
   double   price;
   int      type; // +1 = Swing High, -1 = Swing Low
};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up all indicator objects
   ObjectsDeleteAll(0, OBJ_PREFIX_LINE);
   ObjectsDeleteAll(0, OBJ_PREFIX_BG);
   ObjectsDeleteAll(0, OBJ_PREFIX_ZZ);
   ObjectsDeleteAll(0, OBJ_PREFIX_ARR);
   ObjectsDeleteAll(0, OBJ_PREFIX_SLBOX);
   ObjectsDeleteAll(0, OBJ_PREFIX_PNL);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < (InpLeftRightBars * 2 + 1)) return(0);

   // Set array indexing to series (0 = current candle)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   int limit = MathMin(rates_total - (InpLeftRightBars + 1), InpMaxBars);

   // CALCULATE DYNAMIC 3-GRID-BOX PRICE HEIGHT
   double gridHeightPrice = GetExactGridBoxesPriceHeight(InpGridBoxMultiplier, InpPixelsPerGrid);

   // Signal Counters
   int buyTotal = 0, buyWins = 0, buyLosses = 0, buyOpen = 0;
   int sellTotal = 0, sellWins = 0, sellLosses = 0, sellOpen = 0;

   // --- 1. DRAW MITIGATION LINES, ARROWS & 3-GRID SL BOXES ---
   for(int i = InpLeftRightBars; i <= limit; i++)
   {
      // Check Swing High (Bearish Level to be Mitigated)
      if(IsSwingHigh(high, i, InpLeftRightBars))
      {
         datetime startTime = time[i];
         double price = high[i];
         datetime endTime = time[0];

         for(int j = i - 1; j >= 0; j--)
         {
            if(high[j] >= price) // High Mitigated / Swept
            {
               endTime = time[j];
               
               // Draw Wingdings 234 SELL Arrow
               if(InpShowArrows)
               {
                  double arrowPos = high[j] + (10 * _Point);
                  UpdateWingdingsArrow(OBJ_PREFIX_ARR + "SELL_" + IntegerToString(startTime), time[j], arrowPos, 234, InpSellArrowClr);

                  // Draw Beige SL Box extending EXACTLY 3 GRID BOXES UPWARD
                  if(InpShowSLBox)
                  {
                     datetime boxEndTime = time[MathMax(0, j - InpSLBoxWidthBars)];
                     double boxTopPrice  = high[j] + gridHeightPrice;
                     UpdateSLBox(OBJ_PREFIX_SLBOX + "SELL_" + IntegerToString(startTime), time[j], high[j], boxEndTime, boxTopPrice, InpSLBoxColor, InpSLBoxBorderClr);
                  }

                  // --- SCAN WINRATE FOR SELL SIGNAL USING 3-GRID SL ---
                  sellTotal++;
                  double entry = close[j];
                  double sl    = high[j] + gridHeightPrice; // Exact 3-Grid SL Top
                  double risk  = sl - entry;
                  if(risk <= 0) risk = 10 * _Point;
                  double tp    = entry - (risk * InpRiskReward); // Target TP

                  int outcome  = EvaluateSellSignal(j, sl, tp, low, high);
                  if(outcome == 1)       sellWins++;
                  else if(outcome == -1) sellLosses++;
                  else                   sellOpen++;
               }
               break;
            }
         }
         UpdateTrendLine(OBJ_PREFIX_LINE + "SH_" + IntegerToString(startTime), startTime, price, endTime, price, InpHighColor, InpStyle, InpLineWidth);
      }

      // Check Swing Low (Bullish Level to be Mitigated)
      if(IsSwingLow(low, i, InpLeftRightBars))
      {
         datetime startTime = time[i];
         double price = low[i];
         datetime endTime = time[0];

         for(int j = i - 1; j >= 0; j--)
         {
            if(low[j] <= price) // Low Mitigated / Swept
            {
               endTime = time[j];
               
               // Draw Wingdings 233 BUY Arrow
               if(InpShowArrows)
               {
                  double arrowPos = low[j] - (10 * _Point);
                  UpdateWingdingsArrow(OBJ_PREFIX_ARR + "BUY_" + IntegerToString(startTime), time[j], arrowPos, 233, InpBuyArrowClr);

                  // Draw Beige SL Box extending EXACTLY 3 GRID BOXES DOWNWARD
                  if(InpShowSLBox)
                  {
                     datetime boxEndTime = time[MathMax(0, j - InpSLBoxWidthBars)];
                     double boxBottomPrice = low[j] - gridHeightPrice;
                     UpdateSLBox(OBJ_PREFIX_SLBOX + "BUY_" + IntegerToString(startTime), time[j], low[j], boxEndTime, boxBottomPrice, InpSLBoxColor, InpSLBoxBorderClr);
                  }

                  // --- SCAN WINRATE FOR BUY SIGNAL USING 3-GRID SL ---
                  buyTotal++;
                  double entry = close[j];
                  double sl    = low[j] - gridHeightPrice; // Exact 3-Grid SL Bottom
                  double risk  = entry - sl;
                  if(risk <= 0) risk = 10 * _Point;
                  double tp    = entry + (risk * InpRiskReward); // Target TP

                  int outcome  = EvaluateBuySignal(j, sl, tp, low, high);
                  if(outcome == 1)       buyWins++;
                  else if(outcome == -1) buyLosses++;
                  else                   buyOpen++;
               }
               break;
            }
         }
         UpdateTrendLine(OBJ_PREFIX_LINE + "SL_" + IntegerToString(startTime), startTime, price, endTime, price, InpLowColor, InpStyle, InpLineWidth);
      }
   }

   // --- 2. CALCULATE ALTERNATING WAVE STRUCTURE & HIGHLIGHT BACKGROUND ---
   if(InpShowBackground || InpShowStructure)
   {
      SwingNode swings[];
      BuildAlternatingSwings(time, high, low, limit, swings);

      int count = ArraySize(swings);
      for(int k = 0; k < count - 1; k++)
      {
         datetime t1 = swings[k].time;
         double   p1 = swings[k].price;
         datetime t2 = swings[k+1].time;
         double   p2 = swings[k+1].price;

         if(InpShowStructure)
         {
            UpdateTrendLine(OBJ_PREFIX_ZZ + IntegerToString(t1), t1, p1, t2, p2, InpStructureColor, STYLE_SOLID, InpStructureWidth);
         }

         if(InpShowBackground)
         {
            color bgClr = (swings[k].type == -1 && swings[k+1].type == 1) ? InpBullBgColor : InpBearBgColor;
            UpdateBackgroundRect(OBJ_PREFIX_BG + IntegerToString(t1), t1, t2, bgClr);
         }
      }

      if(count > 0 && InpShowBackground)
      {
         datetime lastT = swings[count-1].time;
         datetime currT = time[0];
         color bgClr = (swings[count-1].type == -1) ? InpBullBgColor : InpBearBgColor;
         UpdateBackgroundRect(OBJ_PREFIX_BG + IntegerToString(lastT), lastT, currT, bgClr);
      }
   }

   // --- 3. DISPLAY RESULTS DASHBOARD HUD ---
   if(InpShowDashboard)
   {
      DrawDashboard(buyTotal, buyWins, buyLosses, buyOpen, sellTotal, sellWins, sellLosses, sellOpen);
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate Price Height of N Screen Grid Boxes                   |
//+------------------------------------------------------------------+
double GetExactGridBoxesPriceHeight(int numGridBoxes, int pixelsPerGrid)
{
   long chartHeightPx = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   double pMax = ChartGetDouble(0, CHART_PRICE_MAX);
   double pMin = ChartGetDouble(0, CHART_PRICE_MIN);

   if(chartHeightPx <= 0 || pMax <= pMin) return(300 * _Point);

   double pricePerPixel = (pMax - pMin) / (double)chartHeightPx;
   double totalPixels = (double)(numGridBoxes * pixelsPerGrid);

   return (totalPixels * pricePerPixel);
}

//+------------------------------------------------------------------+
//| Evaluate Buy Signal Outcome                                      |
//+------------------------------------------------------------------+
int EvaluateBuySignal(int signalBar, double sl, double tp, const double &low[], const double &high[])
{
   for(int k = signalBar - 1; k >= 0; k--)
   {
      bool slHit = (low[k] <= sl);
      bool tpHit = (high[k] >= tp);

      if(slHit && tpHit) return -1; // Loss if both hit on same candle
      if(slHit) return -1;          // Loss
      if(tpHit) return 1;           // Paid / Win
   }
   return 0; // Trade still open
}

//+------------------------------------------------------------------+
//| Evaluate Sell Signal Outcome                                     |
//+------------------------------------------------------------------+
int EvaluateSellSignal(int signalBar, double sl, double tp, const double &low[], const double &high[])
{
   for(int k = signalBar - 1; k >= 0; k--)
   {
      bool slHit = (high[k] >= sl);
      bool tpHit = (low[k] <= tp);

      if(slHit && tpHit) return -1; // Loss if both hit on same candle
      if(slHit) return -1;          // Loss
      if(tpHit) return 1;           // Paid / Win
   }
   return 0; // Trade still open
}

//+------------------------------------------------------------------+
//| Draw/Update Winrate HUD Panel                                    |
//+------------------------------------------------------------------+
void DrawDashboard(int buyTotal, int buyWins, int buyLosses, int buyOpen, 
                   int sellTotal, int sellWins, int sellLosses, int sellOpen)
{
   int buyClosed   = buyWins + buyLosses;
   int sellClosed  = sellWins + sellLosses;
   int totalWins   = buyWins + sellWins;
   int totalClosed = buyClosed + sellClosed;

   double buyWinrate   = (buyClosed > 0)  ? ((double)buyWins / buyClosed) * 100.0 : 0.0;
   double sellWinrate  = (sellClosed > 0) ? ((double)sellWins / sellClosed) * 100.0 : 0.0;
   double totalWinrate = (totalClosed > 0)? ((double)totalWins / totalClosed) * 100.0 : 0.0;

   string bgName = OBJ_PREFIX_PNL + "BG";
   if(ObjectFind(0, bgName) < 0)
   {
      ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bgName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, 15);
      ObjectSetInteger(0, bgName, OBJPROP_XSIZE, 260);
      ObjectSetInteger(0, bgName, OBJPROP_YSIZE, 125);
      ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, C'20,20,25');
      ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, clrDarkGray);
      ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
      ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bgName, OBJPROP_HIDDEN, true);
   }

   string titleStr = StringFormat("=== 3-GRID SL STATS (1:%.1f RR) ===", InpRiskReward);
   string buyStr   = StringFormat("BUY  : %d Paid / %d Loss | %.1f%%", buyWins, buyLosses, buyWinrate);
   string sellStr  = StringFormat("SELL : %d Paid / %d Loss | %.1f%%", sellWins, sellLosses, sellWinrate);
   string totalStr = StringFormat("OVERALL WINRATE: %.1f%% (%d/%d)", totalWinrate, totalWins, totalClosed);

   CreateOrUpdateLabel(OBJ_PREFIX_PNL + "T1", titleStr, 15, 20, clrGold, 9);
   CreateOrUpdateLabel(OBJ_PREFIX_PNL + "T2", buyStr,   15, 45, InpBuyArrowClr, 8);
   CreateOrUpdateLabel(OBJ_PREFIX_PNL + "T3", sellStr,  15, 68, InpSellArrowClr, 8);
   CreateOrUpdateLabel(OBJ_PREFIX_PNL + "T4", totalStr, 15, 95, clrWhite, 9);
}

//+------------------------------------------------------------------+
//| Label Helper Function                                            |
//+------------------------------------------------------------------+
void CreateOrUpdateLabel(string name, string text, int x, int y, color clr, int fontSize)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   }
}

//+------------------------------------------------------------------+
//| Build list of Alternating Major Swings (High -> Low -> High...)   |
//+------------------------------------------------------------------+
void BuildAlternatingSwings(const datetime &time[], const double &high[], const double &low[], int limit, SwingNode &swings[])
{
   ArrayFree(swings);

   for(int i = limit; i >= InpLeftRightBars; i--)
   {
      bool isHigh = IsSwingHigh(high, i, InpLeftRightBars);
      bool isLow  = IsSwingLow(low, i, InpLeftRightBars);

      if(isHigh && !isLow)
      {
         AddOrUpdateSwing(swings, time[i], high[i], 1);
      }
      else if(isLow && !isHigh)
      {
         AddOrUpdateSwing(swings, time[i], low[i], -1);
      }
   }
}

//+------------------------------------------------------------------+
//| Helper to filter consecutive highs/lows for clean wave legs     |
//+------------------------------------------------------------------+
void AddOrUpdateSwing(SwingNode &swings[], datetime t, double p, int type)
{
   int size = ArraySize(swings);
   if(size == 0)
   {
      ArrayResize(swings, 1);
      swings[0].time  = t;
      swings[0].price = p;
      swings[0].type  = type;
      return;
   }

   if(swings[size-1].type == type)
   {
      if((type == 1 && p > swings[size-1].price) || (type == -1 && p < swings[size-1].price))
      {
         swings[size-1].time  = t;
         swings[size-1].price = p;
      }
   }
   else
   {
      ArrayResize(swings, size + 1);
      swings[size].time  = t;
      swings[size].price = p;
      swings[size].type  = type;
   }
}

//+------------------------------------------------------------------+
//| Function to check Swing High                                     |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high[], int index, int range)
{
   double currentHigh = high[index];
   for(int k = 1; k <= range; k++)
   {
      if(high[index - k] >= currentHigh || high[index + k] > currentHigh)
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Function to check Swing Low                                      |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low[], int index, int range)
{
   double currentLow = low[index];
   for(int k = 1; k <= range; k++)
   {
      if(low[index - k] <= currentLow || low[index + k] < currentLow)
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Smooth Trendline Updater                                         |
//+------------------------------------------------------------------+
void UpdateTrendLine(string objName, datetime t1, double p1, datetime t2, double p2, color clr, ENUM_LINE_STYLE style, int width)
{
   if(ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, style);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
   }
   else
   {
      datetime currentEndTime = (datetime)ObjectGetInteger(0, objName, OBJPROP_TIME, 1);
      if(currentEndTime != t2)
      {
         ObjectSetInteger(0, objName, OBJPROP_TIME, 1, t2);
      }
   }
}

//+------------------------------------------------------------------+
//| Background Shading Rectangle Updater                             |
//+------------------------------------------------------------------+
void UpdateBackgroundRect(string objName, datetime t1, datetime t2, color bgClr)
{
   double pMax = 999999.0;
   double pMin = 0.000001;

   if(ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, pMax, t2, pMin);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, bgClr);
      ObjectSetInteger(0, objName, OBJPROP_FILL, true);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
   }
   else
   {
      datetime currentT2 = (datetime)ObjectGetInteger(0, objName, OBJPROP_TIME, 1);
      if(currentT2 != t2)
      {
         ObjectSetInteger(0, objName, OBJPROP_TIME, 1, t2);
      }
   }
}

//+------------------------------------------------------------------+
//| Wingdings Custom Arrow Updater (233 for Buy, 234 for Sell)       |
//+------------------------------------------------------------------+
void UpdateWingdingsArrow(string objName, datetime t, double p, int arrowCode, color clr)
{
   if(ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_ARROW, 0, t, p);
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrowCode);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, InpArrowSize);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   }
   else
   {
      ObjectSetInteger(0, objName, OBJPROP_TIME, 0, t);
      ObjectSetDouble(0, objName, OBJPROP_PRICE, 0, p);
   }
}

//+------------------------------------------------------------------+
//| Stop Loss Box Rectangle Updater                                  |
//+------------------------------------------------------------------+
void UpdateSLBox(string objName, datetime t1, double p1, datetime t2, double p2, color fillClr, color borderClr)
{
   if(ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, borderClr);
      ObjectSetInteger(0, objName, OBJPROP_FILL, true);
      ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, fillClr);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectSetInteger(0, objName, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, objName, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, objName, OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, objName, OBJPROP_PRICE, 1, p2);
   }
}
//+------------------------------------------------------------------+