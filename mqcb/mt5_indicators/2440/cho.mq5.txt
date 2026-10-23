//+---------------------------------------------------------------------+
//|                                                             CHO.mq5 |
//|                         Copyright © 2007, MetaQuotes Software Corp. |
//|                                          https://www.metaquotes.net |
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
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
//--- DarkTurquoise is used as the color of the indicator line
#property indicator_color1 clrDarkTurquoise
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "CHO"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_SMA;          // Method of averaging
input uint FastPeriod=3;                          // Period of fast averaging
input uint SlowPeriod=10;                         // Period of slow averaging
input int XPhase=15;                              // Smoothing parameter
//--- for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // Volume 
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtBuffer[];
//--- declaration of integer variables for storing indicator handles
int Ind_Handle;
//--- declaration of integer variables of data starting point
int  min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_=2;
   int min_rates_1=XMA1.GetStartBars(XMA_Method,FastPeriod,XPhase);
   int min_rates_2=XMA1.GetStartBars(XMA_Method,SlowPeriod,XPhase);
   min_rates_total=min_rates_+int(MathMax(min_rates_1,min_rates_2));
//--- получение хендла индикатора iAD
   Ind_Handle=iAD(Symbol(),PERIOD_CURRENT,VolumeType);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iAD indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"CHO");
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
   if(rates_total<min_rates_total || BarsCalculated(Ind_Handle)<rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar,maxbar;
//--- declaration of variables with a floating point  
   double AD[],Fast,Slow;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(AD,true);
//---   
   maxbar=rates_total-min_rates_-1;
//--- Calculating the required amount of data to copy
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=maxbar;  // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//---   
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,AD)<=0) return(RESET);
//--- the first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {     
      Fast=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,FastPeriod,AD[bar],bar,true);
      Slow=XMA2.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,SlowPeriod,AD[bar],bar,true);
      ExtBuffer[bar]=Fast-Slow;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
