//+------------------------------------------------------------------+
//|                                        FalseBreakoutsCounter.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The indicator counts the number of false breakthrough on the specified number of bars. By "
#property description "false breakthrough means a situation where the high(low) of current bar is above "
#property description "(below) the high(low) of previous bar, and the close of current bar is lower the high (higher the low) of previous bar. "
#property description "Note: if the bar is external to the previous one, then it can have "
#property description "a two false breakthrough."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot FalseBreakouts
#property indicator_label1  "Up False Breakouts"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot FalseBreakouts
#property indicator_label2  "Down False Breakouts"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot FalseBreakouts
#property indicator_label3  "Sum False Breakouts"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//---
#property indicator_minimum 0
//--- input parameters
input int      InpPeriod = 5; // False Breakouts Period
//--- indicator buffers
double         UpFalseBuffer[];
double         DownFalseBuffer[];
double         SumFalseBuffer[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if ( InpPeriod < 1 ) {
      period = 5;
      printf("Incorrected input value InpPeriod = %d. Indicator will use value %d",
         InpPeriod, period);
   } else {
      period = InpPeriod;
   }
//--- indicator buffers mapping
   SetIndexBuffer(0, UpFalseBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownFalseBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, SumFalseBuffer, INDICATOR_DATA);
//---
   for ( int plot = 0; plot < 3; plot++ ) {
      PlotIndexSetInteger(plot, PLOT_DRAW_BEGIN, period);
      PlotIndexSetInteger(plot, PLOT_SHIFT, 0);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "False Breakouts ("+(string)period+")");
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
      Print("Not enough bars for calculations.");
      return(0);
   }
//---
   int start_bar;
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      start_bar = period;
   } else {
      start_bar = prev_calculated - 1;
   }
//---
   for ( int bar = start_bar; bar < rates_total; bar++ ) {
      int up_sum = 0;
      int down_sum = 0;
      
      for ( int pos = bar - period + 1; pos <= bar; pos++ ) {
         int prev = pos - 1;
         
         if ( close[pos] <= high[prev] && high[pos] > high[prev] ) {
            up_sum += 1;
         }
         if ( close[pos] >= low[prev] && low[pos] < low[prev] ) {
            down_sum += 1;
         }
      }
      UpFalseBuffer[bar] = up_sum;
      DownFalseBuffer[bar] = down_sum;
      SumFalseBuffer[bar] = up_sum + down_sum;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
