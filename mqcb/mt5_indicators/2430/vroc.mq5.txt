//+------------------------------------------------------------------+ 
//|                                                         VROC.mq5 | 
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- indigo color is used as the color of the indicator line
#property indicator_color1 BlueViolet
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "VROC"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint PeriodROC=25;                           // Indicator period
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume 
//+-----------------------------------+
//--- declaration of a dynamic array that will be used as an indicator buffer
double ExtLineBuffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| VROC indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(PeriodROC+1);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"VROC(",PeriodROC,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| VROC iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=min_rates_total-1; // starting index for calculation of all bars
   else first=prev_calculated-min_rates_total; // starting index for the calculation of new bars
//--- main calculation loop of the indicator
   if(VolumeType==VOLUME_TICK)
     {
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
         ExtLineBuffer[bar]=((double)tick_volume[bar]-(double)tick_volume[bar-PeriodROC])/(double)tick_volume[bar-PeriodROC]*100;
     }
   else
     {
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
         ExtLineBuffer[bar]=double(((double)volume[bar]-(double)volume[bar-PeriodROC])/(double)volume[bar-PeriodROC]*100);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
