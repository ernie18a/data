//+------------------------------------------------------------------+
//|                                       NarrowestChannelSignal.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The signal occurs if the channel range calculated on the last bar is less "
#property description "than the smallest range, which calculated on the specified number of previous bars."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot CurrentRange
#property indicator_label1  "CurrentRange"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MinRange
#property indicator_label2  "MinRange"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Signal
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//--- input parameters
input int      InpBarsInRange = 3;   // Bars in Range
input int      InpCheckPeriod = 10;    // Check Period
//--- indicator buffers
double         CurrentRangeBuffer[];
double         MinRangeBuffer[];
double         SignalBuffer[];
//---
int            bars_in_range;
int            check_period;
int            min_required_bars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if ( InpCheckPeriod <= 2 || InpBarsInRange < 1 ) {
      bars_in_range = 3;
      check_period = 10;
      printf("Incorrect input value InpBarsInChannel = %d or/and InpCheckPeriod = %d. "
         "Indicator will use value %d and %d respectively.", InpBarsInRange, InpCheckPeriod,
         bars_in_range, check_period);
   } else {
      bars_in_range = InpBarsInRange;
      check_period = InpCheckPeriod;
   }
   min_required_bars = bars_in_range + check_period;
//--- indicator buffers mapping
   SetIndexBuffer(0, CurrentRangeBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, MinRangeBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, SignalBuffer, INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2, PLOT_ARROW, 159);
//---
   for ( int plot = 0; plot < 3; plot++ ) {
      PlotIndexSetInteger(plot, PLOT_DRAW_BEGIN, min_required_bars-1);
      PlotIndexSetInteger(plot, PLOT_SHIFT, 0);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Narrowest Channel Signal ("+(string)bars_in_range
      +", "+(string)check_period+")");
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
   int channel_start_bar, check_start_bar, signal_start_bar;
//---
   if ( rates_total < min_required_bars ) {
      Print("Not enough bars for calculations.");
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      channel_start_bar = bars_in_range - 1;
      check_start_bar = channel_start_bar + check_period;
      signal_start_bar = check_start_bar + 1;
   } else {
      channel_start_bar = prev_calculated - 1;
      check_start_bar = channel_start_bar;
      signal_start_bar = channel_start_bar;
   }
//---
   for ( int bar = channel_start_bar; bar < rates_total; bar++ ) {
      double max_high = high[ArrayMaximum(high, bar-bars_in_range+1, bars_in_range)];
      double min_low = low[ArrayMinimum(low, bar-bars_in_range+1, bars_in_range)];
      
      CurrentRangeBuffer[bar] = max_high - min_low;
   }
   for ( int bar = check_start_bar; bar < rates_total; bar++ ) {
      MinRangeBuffer[bar] = CurrentRangeBuffer[ArrayMinimum(CurrentRangeBuffer, bar-check_period,
         check_period)];
   }
   for ( int bar = signal_start_bar; bar < rates_total; bar++ ) {
      SignalBuffer[bar] = EMPTY_VALUE;
      if ( CurrentRangeBuffer[bar] < MinRangeBuffer[bar]
         && CurrentRangeBuffer[bar-1] >= MinRangeBuffer[bar-1] )
      {
         SignalBuffer[bar] = MinRangeBuffer[bar];
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
