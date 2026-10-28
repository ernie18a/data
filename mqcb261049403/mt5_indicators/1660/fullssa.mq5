//+------------------------------------------------------------------+ 
//|                                                      FullSSA.mq5 | 
//|                                           Copyright © 2007, klot |
//|                                                     klot@mail.ru |
//+------------------------------------------------------------------+ 
//| For the indicator work, place the SSA.mqh file                   |
//| (directory): // in the terminal_data_catalogue\MQL5\Include      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, klot"
#property link      "klot@mail.ru" 
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- magenta color is used
#property indicator_color1 clrMagenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "FullSSA"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Averaging algorithms description            |
//+----------------------------------------------+
#include <SSA.mqh> 
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint Lag=10;
input uint NumComps=2;
input uint PeriodNorm=10;
input uint iN=100;
//+----------------------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],TimeSeriesBuffer[];
//---- Declaration of integer variables for the indicator handles
int MA_Handle,STD_Handle;
//+------------------------------------------------------------------+    
//| FullSSA indicator initialization function                        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(MathMax(Lag,PeriodNorm));

//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,PeriodNorm,0,MODE_SMA,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iStdDev indicator
   STD_Handle=iStdDev(NULL,0,PeriodNorm,0,MODE_SMA,PRICE_CLOSE);
   if(STD_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStdDev indicator");

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as as a buffer for data saving   
   SetIndexBuffer(1,TimeSeriesBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(TimeSeriesBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"FullSSA");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| FullSSA iteration function                                       | 
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(STD_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
      
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-iN);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double MA[],STD[];

//---- calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
      for(bar=rates_total-1; bar>limit && !IsStopped(); bar--) IndBuffer[bar]=0.0;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   if(CopyBuffer(STD_Handle,0,0,to_copy,STD)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(STD,true);
   ArraySetAsSeries(close,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double res=close[bar]-MA[bar];
      if(STD[bar]) TimeSeriesBuffer[bar]=res/(3*STD[bar]);
      else TimeSeriesBuffer[bar]=res/0.1;
     }
//----
   fastsingular(TimeSeriesBuffer,iN,Lag,NumComps,IndBuffer);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
