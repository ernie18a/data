//+---------------------------------------------------------------------+
//|                                                     T3_iAnchMom.mq5 | 
//|                                           Copyright © 2006, Ramdass | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Ramdass"
#property link ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Parameters of indicator drawing   |
//+-----------------------------------+
//--- drawing the indicator as colored labels
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrRed,clrMagenta,clrGray,clrBlue,clrGreen
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "T3_iAnchMom"
//+-----------------------------------+
//| Description of class XMA          |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CT3 class variables from the SmoothAlgorithms.mqh file
CT3 T3A,T3B;
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint FastT3=3;   // Fast T3 period
input uint SlowT3=8;   // Slow T3 period                   
input int T3Phase=15;  // Smoothing parameter
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| T3_iAnchMom indicator initialization function                    | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"T3_iAnchMom");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//--- initialization end
  }
//+------------------------------------------------------------------+ 
//| T3_iAnchMom iteration function                                   | 
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
//--- declaration of variables with a floating point  
   double t3a,t3b;
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      t3a=T3A.T3Series(0,prev_calculated,rates_total,0,T3Phase,FastT3,close[bar],bar,false);
      t3b=T3B.T3Series(0,prev_calculated,rates_total,0,SlowT3,T3Phase,close[bar],bar,false);
      if(t3b) IndBuffer[bar]=100*((t3a/t3b)-1);
      else IndBuffer[bar]=0.0;
     }
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//--- main cycle of the indicator coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---          
   return(rates_total);
  }
//+------------------------------------------------------------------+
