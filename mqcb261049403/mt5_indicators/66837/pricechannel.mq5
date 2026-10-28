//+------------------------------------------------------------------+
//|                                                 PriceChannel.mq5 |
//|                                                        Swordless |
//|                      https://www.mql5.com/zh/users/xwj-ventures/ |
//+------------------------------------------------------------------+
#property copyright "Swordless"
#property link      "https://www.mql5.com/zh/users/xwj-ventures/"
#property version   "1.00"
//--- indicator properties
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Upper Line"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Lower Line"
//--- input
input int     ChannelPeriod = 10;               // Channel Period
input color   UpperLineColor = clrDodgerBlue;   // Upper Line Color
input color   LowerLineColor = clrMagenta;      // Lower Line Color
//--- indicator buffers
double UpperBuffer[],
       LowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LowerBuffer, INDICATOR_DATA);
//--- set line colors
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, UpperLineColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, LowerLineColor);
//--- set indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Price Channel (" + string(ChannelPeriod) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- set beginning
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ChannelPeriod - 1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, ChannelPeriod - 1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//--- there must be enough data
   if(rates_total < ChannelPeriod)
      return(0);
//--- calculate beginning
   int start;
   if(prev_calculated == 0)
      start = ChannelPeriod - 1;
   else
      start = prev_calculated - 1;
//--- calculate indicator
   for(int i = start; i < rates_total; i++)
     {
      double highest = high[i];
      double lowest = low[i];
      // be careful of the earliest bars
      int lookback = MathMin(i, ChannelPeriod - 1);
      for(int j = 1; j <= lookback; j++)
        {
         int idx = i - j;
         if(idx >= 0)
           {
            double currentHigh = high[idx];
            double currentLow = low[idx];
            if(currentHigh > highest)
               highest = currentHigh;
            if(currentLow < lowest)
               lowest = currentLow;
           }
        }
      // set channel data
      UpperBuffer[i] = highest;
      LowerBuffer[i] = lowest;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
