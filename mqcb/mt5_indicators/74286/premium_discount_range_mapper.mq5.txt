//+------------------------------------------------------------------+
//|                                    Premium Discount Range Mapper |
//|                               Educational indicator for MQL5.com |
//+------------------------------------------------------------------+
#property copyright "Talal N Z Aljarusha"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input double   InpRangeHigh          = 0.0;             // Manual range high, 0 = auto
input double   InpRangeLow           = 0.0;             // Manual range low, 0 = auto
input int      InpAutoLookbackBars   = 120;             // Auto range lookback bars
input int      InpExtendBars         = 80;              // Extend zones to the right
input bool     InpShowQuarterLevels  = true;            // Show 25% and 75% levels
input bool     InpShowPriceLabels    = true;            // Show level names and prices
input color    InpPremiumColor       = clrMistyRose;    // Premium zone color
input color    InpEquilibriumColor   = clrGainsboro;    // Equilibrium band color
input color    InpDiscountColor      = clrPaleGreen;    // Discount zone color
input color    InpLineColor          = clrSlateGray;    // Level line color
input int      InpTransparency       = 72;              // Zone transparency, 0-255
input string   InpObjectPrefix       = "PDRM_";         // Object prefix

//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Premium Discount Range Mapper");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteObjects();
}

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
   if(rates_total < 20)
      return(rates_total);

   DeleteObjects();

   double rangeHigh = InpRangeHigh;
   double rangeLow  = InpRangeLow;
   int    leftIndex = 0;

   if(rangeHigh <= 0.0 || rangeLow <= 0.0 || rangeHigh <= rangeLow)
   {
      FindAutoRange(rates_total, high, low, rangeHigh, rangeLow, leftIndex);
   }
   else
   {
      leftIndex = MathMax(0, rates_total - MathMax(InpAutoLookbackBars, 20));
   }

   if(rangeHigh <= rangeLow)
      return(rates_total);

   DrawRange(time[leftIndex], time[rates_total - 1], rangeHigh, rangeLow);
   ChartRedraw(0);
   return(rates_total);
}

//+------------------------------------------------------------------+
void FindAutoRange(const int rates_total,
                   const double &high[],
                   const double &low[],
                   double &rangeHigh,
                   double &rangeLow,
                   int &leftIndex)
{
   const int lookback = MathMax(20, MathMin(InpAutoLookbackBars, rates_total - 1));
   const int start    = rates_total - lookback;

   rangeHigh = high[start];
   rangeLow  = low[start];
   leftIndex = start;

   for(int i = start; i < rates_total; i++)
   {
      if(high[i] > rangeHigh)
         rangeHigh = high[i];

      if(low[i] < rangeLow)
         rangeLow = low[i];
   }
}

//+------------------------------------------------------------------+
void DrawRange(const datetime leftTime,
               const datetime lastBarTime,
               const double rangeHigh,
               const double rangeLow)
{
   const double range = rangeHigh - rangeLow;
   const double lvl75 = rangeLow + range * 0.75;
   const double lvl50 = rangeLow + range * 0.50;
   const double lvl25 = rangeLow + range * 0.25;

   const int periodSeconds = MathMax(PeriodSeconds(_Period), 60);
   const datetime rightTime = lastBarTime + periodSeconds * MathMax(5, InpExtendBars);

   DrawZone("PREMIUM", leftTime, rightTime, rangeHigh, lvl50, InpPremiumColor);
   DrawZone("DISCOUNT", leftTime, rightTime, lvl50, rangeLow, InpDiscountColor);
   DrawZone("EQBAND", leftTime, rightTime, lvl50 + range * 0.015, lvl50 - range * 0.015, InpEquilibriumColor);

   DrawLevel("HIGH", leftTime, rightTime, rangeHigh, "Range High");
   DrawLevel("EQ", leftTime, rightTime, lvl50, "Equilibrium 50%");
   DrawLevel("LOW", leftTime, rightTime, rangeLow, "Range Low");

   if(InpShowQuarterLevels)
   {
      DrawLevel("Q75", leftTime, rightTime, lvl75, "Premium 75%");
      DrawLevel("Q25", leftTime, rightTime, lvl25, "Discount 25%");
   }

   DrawSideLabel("PREMIUM_LABEL", rightTime, (rangeHigh + lvl50) * 0.5, "Premium");
   DrawSideLabel("EQ_LABEL", rightTime, lvl50, "Equilibrium");
   DrawSideLabel("DISCOUNT_LABEL", rightTime, (lvl50 + rangeLow) * 0.5, "Discount");
}

//+------------------------------------------------------------------+
void DrawZone(const string suffix,
              const datetime leftTime,
              const datetime rightTime,
              const double top,
              const double bottom,
              const color baseColor)
{
   const string name = InpObjectPrefix + suffix;
   color zoneColor = (color)ColorToARGB(baseColor, (uchar)MathMax(0, MathMin(255, InpTransparency)));

   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, leftTime, top, rightTime, bottom))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, zoneColor);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
void DrawLevel(const string suffix,
               const datetime leftTime,
               const datetime rightTime,
               const double price,
               const string text)
{
   const string lineName = InpObjectPrefix + suffix + "_LINE";

   if(ObjectCreate(0, lineName, OBJ_TREND, 0, leftTime, price, rightTime, price))
   {
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpLineColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, suffix == "EQ" ? STYLE_SOLID : STYLE_DOT);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, suffix == "EQ" ? 2 : 1);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
   }

   if(!InpShowPriceLabels)
      return;

   const string label = text + "  " + DoubleToString(price, _Digits);
   DrawSideLabel(suffix + "_TEXT", rightTime, price, label);
}

//+------------------------------------------------------------------+
void DrawSideLabel(const string suffix,
                   const datetime labelTime,
                   const double price,
                   const string text)
{
   const string name = InpObjectPrefix + suffix;

   if(!ObjectCreate(0, name, OBJ_TEXT, 0, labelTime, price))
      return;

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpLineColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
void DeleteObjects()
{
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      const string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, InpObjectPrefix) == 0)
         ObjectDelete(0, name);
   }
}
