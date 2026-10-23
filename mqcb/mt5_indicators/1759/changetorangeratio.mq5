//+------------------------------------------------------------------+
//|                                                  ChangeRatio.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The indicator shows the ratio of the price change to the sum of bar ranges of the period. "
#property description "Can be used as a signal to close a position or as an entry filter."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Ratio
#property indicator_label1  "Ratio"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//---
#property indicator_minimum -1.0
#property indicator_maximum +1.0
#property indicator_level1 0.0
#property indicator_level2 -0.5
#property indicator_level3 0.5
//--- input parameters
input int      InpChangeRatioPeriod = 3; // Change Ratio Period
//--- indicator buffers
double         RatioBuffer[];
//---
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if ( InpChangeRatioPeriod < 2 ) {
      period = 3;
      printf("Incorrected input value InpChangeRatioPeriod = %d. Indicator will use value %d",
         InpChangeRatioPeriod, period);
   } else {
      period = InpChangeRatioPeriod;
   }
//--- indicator buffers mapping
   SetIndexBuffer(0, RatioBuffer, INDICATOR_DATA);
//---
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, period-1);
   PlotIndexSetInteger(0, PLOT_SHIFT, 0);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//---
   IndicatorSetInteger(INDICATOR_DIGITS, 5);
   IndicatorSetString(INDICATOR_SHORTNAME, "Change To Range Ratio ("+(string)period+")");
//---
   return(0);
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
//---
   if ( rates_total < period ) {
      Print("Not enough bars for calculations");
      return(0);
   }
   int start_bar;
   
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      start_bar = period;
   } else {
      start_bar = prev_calculated - 1;
   }
//---
   for ( int bar = start_bar; bar < rates_total; bar++ ) {
      int shift = bar - period + 1;
      double sum = 0.0;
      
      for ( ; shift <= bar; shift++ ) {
         sum += (high[shift] - low[shift]);
      }
      if ( sum == 0.0 ) {
         RatioBuffer[bar] = 0.0;
      } else {
         RatioBuffer[bar] = (close[bar] - close[bar-period]) / sum;
      }
   }  
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
