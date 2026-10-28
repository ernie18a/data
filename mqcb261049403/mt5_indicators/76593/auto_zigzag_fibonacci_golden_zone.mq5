//+------------------------------------------------------------------+
//|                                   Auto_ZigZag_Fibonacci_Zone.mq5 |
//|                                 Copyright 2026, BILLION KPG CLUB |
//+------------------------------------------------------------------+
#property copyright "BILLION KPG CLUB"
#property version   "1.10"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property description "Auto ZigZag Fibonacci Golden Zone indicator for MetaTrader 5."
#property description "Identifies optimal pullback entry zones using Fibonacci levels."
#property description "Developed by BILLION KPG CLUB."

//--- Input parameters
input group "=== ZigZag Settings ==="
input int    InpLength            = 13;    // Zig Zag Length
input bool   InpShowPrices        = true;  // Show Swing Prices
input int    InpZoneLengthBars    = 15;    // Golden Zone Length (bars)
input bool   InpShowBuySellSignals= false; // Show Buy / Sell Signals

input group "=== ZigZag Colors ==="
input color  InpZZTopColor        = clrDodgerBlue; // Zig Zag Top Label Color
input color  InpZZColor           = clrGray;       // Zig Zag Trend Line Color
input color  InpZZBotColor        = clrOrangeRed;  // Zig Zag Bottom Label Color

input group "=== Fibonacci & Golden Zone Colors ==="
input color  InpFib50Color        = C'82,255,226'; // Fib 50% Line Color
input color  InpFib618Color       = clrGold;       // Fib 61.8% Line Color
input color  InpFib786Color       = clrDarkGoldenrod;       // Fib 78.6% Line Color
input color  InpGoldenZoneColor   = C'255,255,200'; // Golden Zone Fill Color
input color  InpGoldenZoneLabel   = clrYellow;     // Golden Zone Text Color

//--- Global variables
double g_valTop = 0, g_valBottom = 0;
double g_valTopDraw = 0, g_valBottomDraw = 0;
int    g_topBar = -1, g_bottomBar = -1;
int    g_prevOs = -1;
bool   g_prevSell1 = false, g_prevSell2 = false;
bool   g_prevBuy1 = false, g_prevBuy2 = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Delete old objects to ensure a clean start
   ObjectsDeleteAll(0, "KPG_");
   return(INIT_SUCCEEDED);
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
   if(rates_total < InpLength + 3) return 0;

   // --- SPEED OPTIMIZATION: Exit if no new data ---
   if(prev_calculated == rates_total) return(rates_total);

   // Set arrays as series (index 0 is the most recent candle) - Standard MQL5 syntax
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   // Determine the range to process
   int start;
   if(prev_calculated == 0)
   {
      // First run: process all available data
      start = 0;
      // Reset state
      g_valTop = 0; g_valBottom = 0;
      g_valTopDraw = 0; g_valBottomDraw = 0;
      g_topBar = -1; g_bottomBar = -1;
      g_prevOs = -1;
      g_prevSell1 = false; g_prevSell2 = false;
      g_prevBuy1 = false; g_prevBuy2 = false;
   }
   else
   {
      // Subsequent runs: only process new bars plus a safety margin
      start = MathMax(prev_calculated - InpLength - 1, 0);
   }

   // Ensure start does not exceed the safe limit
   if(start > rates_total - 2) start = rates_total - 2;

   // Process from the most recent closed bar down to 'start'
   for(int i = rates_total - 2; i >= start; i--)
   {
      // --- FIX: Strict array bounds check ---
      // We need i + InpLength + 1 < rates_total to safely access high[i+1+InpLength]
      if(i + InpLength + 1 >= rates_total) continue;

      // Calculate ZigZag based on closed candles (i+1) to avoid repainting
      double upper = high[i+1];
      double lower = low[i+1];
      for(int j = 1; j < InpLength; j++)
      {
         int idx = i + 1 + j;
         if(idx >= rates_total) break; // SAFETY CHECK
         if(high[idx] > upper) upper = high[idx];
         if(low[idx] < lower) lower = low[idx];
      }

      int os = g_prevOs;
      int idxEnd = i + 1 + InpLength; // must be < rates_total due to check above
      if(high[idxEnd] >= upper) os = 0;
      else if(low[idxEnd] <= lower) os = 1;

      bool pl = (os == 1 && g_prevOs != 1);
      bool ph = (os == 0 && g_prevOs != 0);

      // Handle Pivot Low
      if(pl)
      {
         g_valBottom = low[idxEnd];
         g_bottomBar = idxEnd;
         g_valBottomDraw = g_valBottom;

         if(g_topBar >= 0 && g_valTop > 0)
            DrawTrend(time[g_topBar], g_valTop, time[g_bottomBar], g_valBottom, InpZZColor);

         if(g_valTopDraw > 0 && g_valBottomDraw > 0)
         {
            DeleteFibObjects();
            DrawFibLevels(time[g_bottomBar], true); // true = Measuring from High to Low
         }

         if(InpShowPrices && g_bottomBar >= 0)
            DrawLabel("KPG_BOT_PRICE", time[g_bottomBar], g_valBottom, DoubleToString(g_valBottom, _Digits), InpZZBotColor, false);
      }

      // Handle Pivot High
      if(ph)
      {
         g_valTop = high[idxEnd];
         g_topBar = idxEnd;
         g_valTopDraw = g_valTop;

         if(g_bottomBar >= 0 && g_valBottom > 0)
            DrawTrend(time[g_bottomBar], g_valBottom, time[g_topBar], g_valTop, InpZZColor);

         if(g_valTopDraw > 0 && g_valBottomDraw > 0)
         {
            DeleteFibObjects();
            DrawFibLevels(time[g_topBar], false); // false = Measuring from Low to High
         }

         if(InpShowPrices && g_topBar >= 0)
            DrawLabel("KPG_TOP_PRICE", time[g_topBar], g_valTop, DoubleToString(g_valTop, _Digits), InpZZTopColor, true);
      }

      g_prevOs = os;

      // Buy/Sell Signal Logic - Only evaluate when i == 1 (most recent closed candle)
      if(g_topBar >= 0 && g_bottomBar >= 0 && g_valTopDraw > 0 && g_valBottomDraw > 0 && i == 1)
      {
         double range = g_valTopDraw - g_valBottomDraw;

         // --- SELL SIGNAL (Downtrend pullback) ---
         double fib618_sell = range * 0.618 + g_valBottomDraw;
         double fib786_sell = range * 0.786 + g_valBottomDraw;

         bool isSell = (close[i] < fib786_sell && close[i] > fib618_sell &&
                        os == 0 && close[i] < open[i] &&
                        !g_prevSell1 && !g_prevSell2);

         // --- BUY SIGNAL (Uptrend pullback) ---
         double fib618_buy = range * 0.382 + g_valBottomDraw;
         double fib786_buy = range * 0.236 + g_valBottomDraw;

         bool isBuy = (close[i] > fib786_buy && close[i] < fib618_buy &&
                       os == 1 && close[i] > open[i] &&
                       !g_prevBuy1 && !g_prevBuy2);

         if(InpShowBuySellSignals)
         {
            if(isSell) DrawSignal(time[i], high[i], "Sell Pullback", clrRed, true);
            if(isBuy)  DrawSignal(time[i], low[i], "Buy Pullback", clrLime, false);
         }

         g_prevSell2 = g_prevSell1; g_prevSell1 = isSell;
         g_prevBuy2 = g_prevBuy1;   g_prevBuy1 = isBuy;
      }
   }

   DrawDashboard(close[0]);
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Helper: Delete old Fib objects to prevent clutter                |
//+------------------------------------------------------------------+
void DeleteFibObjects()
{
   ObjectDelete(0, "KPG_FIB_500");
   ObjectDelete(0, "KPG_FIB_618");
   ObjectDelete(0, "KPG_FIB_786");
   ObjectDelete(0, "KPG_GOLDEN_ZONE");
   ObjectDelete(0, "KPG_GOLDEN_LABEL");
}

//+------------------------------------------------------------------+
//| Helper: Draw Fibonacci Levels                                    |
//+------------------------------------------------------------------+
void DrawFibLevels(datetime startTime, bool isMeasuringFromHigh)
{
   double range = g_valTopDraw - g_valBottomDraw;
   if(range <= 0) return;

   // Draw Golden Zone extending into the future (to the right)
   datetime endTime = startTime + PeriodSeconds() * InpZoneLengthBars;

   double fib500 = (g_valTopDraw + g_valBottomDraw) / 2.0;
   double fib618, fib786;

   // isMeasuringFromHigh determines the Fibonacci measurement direction
   if(isMeasuringFromHigh) // Measuring from High down to Low (downtrend)
   {
      fib618 = range * 0.382 + g_valBottomDraw;
      fib786 = range * 0.214 + g_valBottomDraw; // FIXED: 0.214 instead of 0.236
   }
   else // Measuring from Low up to High (uptrend)
   {
      fib618 = range * 0.618 + g_valBottomDraw;
      fib786 = range * 0.786 + g_valBottomDraw;
   }

   CreateHLine("KPG_FIB_500", fib500, InpFib50Color, STYLE_SOLID, 1);
   CreateHLine("KPG_FIB_618", fib618, InpFib618Color, STYLE_SOLID, 2);
   CreateHLine("KPG_FIB_786", fib786, InpFib786Color, STYLE_SOLID, 2);

   // Draw Golden Zone Rectangle
   ObjectCreate(0, "KPG_GOLDEN_ZONE", OBJ_RECTANGLE, 0, startTime, fib618, endTime, fib786);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_BGCOLOR, InpGoldenZoneColor);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_COLOR, InpGoldenZoneColor);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_BACK, true);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_FILL, true);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "KPG_GOLDEN_ZONE", OBJPROP_SELECTABLE, false);

   double labelPrice = isMeasuringFromHigh ? fib786 : fib618;
   ObjectCreate(0, "KPG_GOLDEN_LABEL", OBJ_TEXT, 0, startTime, labelPrice);
   ObjectSetString(0, "KPG_GOLDEN_LABEL", OBJPROP_TEXT, "Golden Zone");
   ObjectSetInteger(0, "KPG_GOLDEN_LABEL", OBJPROP_COLOR, InpGoldenZoneLabel);
   ObjectSetInteger(0, "KPG_GOLDEN_LABEL", OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, "KPG_GOLDEN_LABEL", OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Helper: Draw Trend Line                                          |
//+------------------------------------------------------------------+
void DrawTrend(datetime t1, double p1, datetime t2, double p2, color clr)
{
   string name = "KPG_ZZ_" + TimeToString(t2);
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Helper: Create Horizontal Line                                   |
//+------------------------------------------------------------------+
void CreateHLine(string name, double price, color clr, ENUM_LINE_STYLE style, int width)
{
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Helper: Draw Text Label                                          |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime t, double p, string text, color clr, bool isTop)
{
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, isTop ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Helper: Draw Signal Label                                        |
//+------------------------------------------------------------------+
void DrawSignal(datetime t, double p, string text, color clr, bool isSell)
{
   string name = "KPG_SIGNAL_" + TimeToString(t);
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Helper: Draw Dashboard Panel                                     |
//+------------------------------------------------------------------+
void DrawDashboard(double currentPrice)
{
   int x = 10, y = 30;
   string bg = "KPG_DASH_BG";

   if(ObjectFind(0, bg) < 0)
   {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x - 5);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y - 5);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, 280);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, 260);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'20,20,40');
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   }

   SetDashText("KPG_DASH_TITLE", x, y, "=== KPG SMART FIB ===", clrGold); y += 20;

   // REMOVED: Trend direction line (Bullish/Bearish) as requested

   SetDashText("KPG_DASH_PRICE", x, y, "Price: " + DoubleToString(currentPrice, _Digits), clrWhite); y += 20;
   SetDashText("KPG_DASH_HIGH", x, y, "Swing High: " + DoubleToString(g_valTopDraw, _Digits), clrRed); y += 20;
   SetDashText("KPG_DASH_LOW", x, y, "Swing Low: " + DoubleToString(g_valBottomDraw, _Digits), clrBlue); y += 20;

   double range = g_valTopDraw - g_valBottomDraw;
   if(range > 0)
   {
      bool isMeasuringFromHigh = (g_topBar < g_bottomBar);
      double fib618 = isMeasuringFromHigh ? range * 0.382 + g_valBottomDraw : range * 0.618 + g_valBottomDraw;
      double fib786 = isMeasuringFromHigh ? range * 0.214 + g_valBottomDraw : range * 0.786 + g_valBottomDraw; // FIXED: 0.214 instead of 0.236

      SetDashText("KPG_DASH_F618", x, y, "Fib 61.8%: " + DoubleToString(fib618, _Digits), clrYellow); y += 20;
      SetDashText("KPG_DASH_F786", x, y, "Fib 78.6%: " + DoubleToString(fib786, _Digits), clrYellow); y += 25;
   }

   SetDashText("KPG_DASH_HOW_TITLE", x, y, "=== HOW TO USE ===", clrCyan); y += 20;
   SetDashText("KPG_DASH_HOW1", x, y, "1. Wait for price to enter", clrWhite); y += 16;
   SetDashText("KPG_DASH_HOW2", x, y, "   the Golden Zone", clrWhite); y += 16;
   SetDashText("KPG_DASH_HOW3", x, y, "2. Downtrend: SELL at 61.8-78.6%", clrYellow); y += 16;
   SetDashText("KPG_DASH_HOW4", x, y, "3. Uptrend: BUY at 61.8-78.6%", clrLime); y += 16;
   SetDashText("KPG_DASH_HOW5", x, y, "4. Place SL outside Golden Zone", clrOrange);
}

//+------------------------------------------------------------------+
//| Helper: Set Dashboard Text                                       |
//+------------------------------------------------------------------+
void SetDashText(string name, int x, int y, string text, color clr)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "KPG_");
}
//+------------------------------------------------------------------+