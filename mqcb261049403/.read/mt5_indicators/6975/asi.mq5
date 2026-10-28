//+------------------------------------------------------------------+
//|                                                          ASI.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
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
//--- Coral is used as the color of the indicator line
#property indicator_color1 clrCoral
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "ASI"
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint T = 300;        // Deviation limit
input uint ATRPeriod=1;    // ATR period
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtBuffer[];
//--- declaration of integer variables for storing indicator handles
int Ind_Handle;
//---
double dT;
//--- declaration of integer variables of data starting point
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(ATRPeriod+1);
//--- getting handle of the iATR indicator
   Ind_Handle=iATR(Symbol(),PERIOD_CURRENT,ATRPeriod);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the iATR indicator handle");
      return(INIT_FAILED);
     }
//--- shift initialization
   dT=_Point*T;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ASI");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   int to_copy,limit,bar,bar1;
//--- declaration of variables with a floating point  
   double ATR[],TR,ER,K,SH,R,res;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- calculating the required amount of data to copy
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      bar1=limit+1;
      ExtBuffer[bar1]=high[bar1]-low[bar1];
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//---   
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- the first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar1=bar+1;
      TR=ATR[bar];
      if(close[bar+1]>=low[bar] && close[bar+1]<=high[bar]) ER=0.0;
      else
        {
         if(close[bar1]> high[bar]) ER=MathAbs(high[bar]-close[bar1]);
         if(close[bar1] < low[bar]) ER=MathAbs(low[bar]-close[bar1]);
        }
      K=MathMax(MathAbs(high[bar]-close[bar1]),MathAbs(low[bar]-close[bar1]));
      SH= MathAbs(close[bar1]-open[bar1]);
      R = TR-0.5*ER+0.25*SH;
      if(R) res=50*(close[bar]-close[bar+1]+0.5*(close[bar]-open[bar])+0.25*(close[bar+1]-open[bar+1]))*(K/dT)/R;
      else res=0.0;
      ExtBuffer[bar]=ExtBuffer[bar+1]+res;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+