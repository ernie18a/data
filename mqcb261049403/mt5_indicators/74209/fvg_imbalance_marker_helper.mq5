//+------------------------------------------------------------------+
//|                                      FVG Imbalance Marker Helper |
//|                               Educational indicator for MQL5.com |
//+------------------------------------------------------------------+
#property copyright "Talal N Z Aljarusha"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input int      InpLookbackBars       = 500;            // Bars to scan
input int      InpMinGapPoints       = 80;             // Minimum gap size, points
input int      InpExtendBars         = 4;              // Rectangle extension, bars
input bool     InpHideFilledGaps     = false;          // Hide gaps touched by later price
input color    InpBullishColor       = clrPaleGreen;   // Bullish FVG color
input color    InpBearishColor       = clrMistyRose;   // Bearish FVG color
input int      InpTransparency       = 70;             // Transparency, 0-255
input string   InpObjectPrefix       = "FVG_HELPER_";  // Object prefix

//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "FVG Imbalance Marker Helper");
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
   if(rates_total < 5)
      return(rates_total);

   DeleteObjects();

   const int start = MathMax(2, rates_total - MathMax(InpLookbackBars, 10));
   const int last  = rates_total - 2;

   for(int i = start; i <= last; i++)
   {
      CheckBullishGap(i, time, high, low, rates_total);
      CheckBearishGap(i, time, high, low, rates_total);
   }

   ChartRedraw(0);
   return(rates_total);
}

//+------------------------------------------------------------------+
void CheckBullishGap(const int i,
                     const datetime &time[],
                     const double &high[],
                     const double &low[],
                     const int rates_total)
{
   // Three-candle bullish FVG: candle 3 low remains above candle 1 high.
   const double gapBottom = high[i - 2];
   const double gapTop    = low[i];
   const double gapPoints = (gapTop - gapBottom) / _Point;

   if(gapPoints < InpMinGapPoints)
      return;

   if(InpHideFilledGaps && IsBullishGapFilled(i + 1, rates_total, gapBottom, low))
      return;

   DrawGap(i, time, gapTop, gapBottom, true);
}

//+------------------------------------------------------------------+
void CheckBearishGap(const int i,
                     const datetime &time[],
                     const double &high[],
                     const double &low[],
                     const int rates_total)
{
   // Three-candle bearish FVG: candle 3 high remains below candle 1 low.
   const double gapTop    = low[i - 2];
   const double gapBottom = high[i];
   const double gapPoints = (gapTop - gapBottom) / _Point;

   if(gapPoints < InpMinGapPoints)
      return;

   if(InpHideFilledGaps && IsBearishGapFilled(i + 1, rates_total, gapTop, high))
      return;

   DrawGap(i, time, gapTop, gapBottom, false);
}

//+------------------------------------------------------------------+
bool IsBullishGapFilled(const int start,
                        const int rates_total,
                        const double gapBottom,
                        const double &low[])
{
   for(int j = start; j < rates_total; j++)
   {
      if(low[j] <= gapBottom)
         return(true);
   }

   return(false);
}

//+------------------------------------------------------------------+
bool IsBearishGapFilled(const int start,
                        const int rates_total,
                        const double gapTop,
                        const double &high[])
{
   for(int j = start; j < rates_total; j++)
   {
      if(high[j] >= gapTop)
         return(true);
   }

   return(false);
}

//+------------------------------------------------------------------+
void DrawGap(const int i,
             const datetime &time[],
             const double top,
             const double bottom,
             const bool bullish)
{
   const string side = bullish ? "BULL_" : "BEAR_";
   const string name = InpObjectPrefix + side + IntegerToString((int)time[i]);

   datetime rightTime = time[i] + PeriodSeconds(_Period) * MathMax(1, InpExtendBars);
   color    zoneColor = bullish ? InpBullishColor : InpBearishColor;
   zoneColor = (color)ColorToARGB(zoneColor, (uchar)MathMax(0, MathMin(255, InpTransparency)));

   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time[i - 2], top, rightTime, bottom))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, zoneColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

   DrawLabel(name + "_LABEL", time[i], (top + bottom) * 0.5, bullish);
}

//+------------------------------------------------------------------+
void DrawLabel(const string name,
               const datetime labelTime,
               const double price,
               const bool bullish)
{
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, labelTime, price))
      return;

   ObjectSetString(0, name, OBJPROP_TEXT, bullish ? "FVG Bullish" : "FVG Bearish");
   ObjectSetInteger(0, name, OBJPROP_COLOR, bullish ? clrSeaGreen : clrTomato);
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
