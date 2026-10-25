//+------------------------------------------------------------------+
//|                                                     CronexAC.mq5 |
//|                                        Copyright © 2007, Cronex. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Cronex"
#property  link      "https://www.metaquotes.net/"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator drawing parameters                 |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrDodgerBlue,clrOrange
//--- displaying the indicator label
#property indicator_label1  "CronexAC"
//+----------------------------------------------+
//| CXMA class description                       |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//| declaration of enumerations                  |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA;   // Smoothing method
input uint FastPeriod=14;                  // Period of fast smoothing
input uint SlowPeriod=25;                  // Period of slow smoothing
input int XPhase=15;                       // Smoothing parameter
//--- for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtABuffer[],ExtBBuffer[];
//--- declaration of integer variables for storing indicator handles
int Ind_Handle;
//--- declaration of integer variables of data starting point
int  min_rates_1,min_rates_2,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=37;
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,FastPeriod,XPhase);
   min_rates_total=min_rates_2+XMA1.GetStartBars(XMA_Method,SlowPeriod,XPhase);
//--- getting the handle of the iAC indicator
   Ind_Handle=iAC(Symbol(),PERIOD_CURRENT);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iAC indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtABuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"CronexAC");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  { 
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total || BarsCalculated(Ind_Handle)<rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar,maxbar1,maxbar2;
//--- declaration of variables with a floating point  
   double iInd[];
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(iInd,true);
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_1-1;     // Starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//---   
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,iInd)<=0) return(RESET);
//---   
   maxbar1=rates_total-min_rates_1-1;
   maxbar2=rates_total-min_rates_2-1;
//--- the first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtABuffer[bar]=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,XMA_Method,XPhase,FastPeriod,iInd[bar],bar,true);
      ExtBBuffer[bar]=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,XMA_Method,XPhase,SlowPeriod,ExtABuffer[bar],bar,true);
     } 
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
