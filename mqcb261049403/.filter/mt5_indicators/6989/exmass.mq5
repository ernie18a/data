//+------------------------------------------------------------------+
//|                                                       ExMass.mq4 |
//|                           Copyright © 2006, Alex Sidd (Executer) |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alex Sidd (Executer)"
#property link      "mailto:work_st@mail.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 1
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- SlateBlue color is used as the color of the indicator line
#property indicator_color1 clrSlateBlue
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "ExMass"
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint ExPeriod=8;     // Period
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtBuffer[];
//--- declaration of integer variables of data starting point
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(ExPeriod);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ExMass");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int limit,bar;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- calculations of the necessary amount of data to be copied 
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//--- the first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double positive=high[ArrayMaximum(high,bar,ExPeriod)];
      double negative=low[ArrayMinimum(low,bar,ExPeriod)];
      ExtBuffer[bar]=(positive-negative)/_Point;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
