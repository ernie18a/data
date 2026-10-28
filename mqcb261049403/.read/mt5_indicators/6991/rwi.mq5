//+------------------------------------------------------------------+
//| RWI.mq5                                                          |
//| Random Walk Index                                                |
//| From MetaStock Indicator: Random Walk Index by E. Michael Poulos |
//| Ramdass                                                          |
//+------------------------------------------------------------------+
//  Random Walk Index is used for defining whether,                  |
//  the market instrument is in a developing trend or                |
//  performs random motion in a trading range.                       |
//  This indicator tries to do it by defining a trading              |
//  range of the market instrument first. The next step              |
//  step is to calculate a series of RWI indices for                 |
//  the maximum of the analyzed period. The largest movement of      |
//  the index relative to RW is used as the current index.           |
//  The market develops an uptrend, if RWI of highs > 1,             |
//  while the downtrend is when RWI of lows > 1.                     |
//                                                                   |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Ramdass"
#property  link      ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrDodgerBlue,clrDeepPink
//--- displaying the indicator label
#property indicator_label1  "RWI"
//+----------------------------------------------+
//| CXMA class description                       |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  declaration of enumerations                 |
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
input uint RWI_Period=25;                        // RWI indicator period
input Smooth_Method XMA_Method=MODE_JJMA;        // Method of averaging
input uint XPeriod=5;                            // Smoothing period
input int XPhase=15;                             // Smoothing parameter
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtABuffer[],ExtBBuffer[];
//--- declaration of integer variables for storing indicator handles
int Ind_Handle;
//--- declaration of integer variables of data starting point
int  min_rates_1,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=int(RWI_Period)+1;
   min_rates_total=min_rates_1+XMA1.GetStartBars(XMA_Method,XPeriod,XPhase);
//--- getting handle of the iATR indicator
   Ind_Handle=iATR(Symbol(),PERIOD_CURRENT,RWI_Period);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the iATR indicator handle");
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
   IndicatorSetString(INDICATOR_SHORTNAME,"RWI");
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
   double iInd[],max_High,max_Low,res,max_1,max_2;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(iInd,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_1-1; // Starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//---   
   to_copy=limit+1+int(RWI_Period);
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,iInd)<=0) return(RESET);
//---
   maxbar=rates_total-min_rates_1-1;
//--- the first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      max_High=0.0;
      max_Low=0.0;
      for(int kkk=0; kkk<int(RWI_Period); kkk++)
        {
         res=MathSqrt(kkk+1)*iInd[bar+kkk];
         if(res)
           {
            max_1=(high[bar]-low[bar+kkk])/res;   // RWI_High Index
            max_2=(high[bar+kkk]-low[bar])/res;   // RWI_Low Index
            if(max_1>max_High) max_High = max_1;  // Maximum_RWI_High Index
            if(max_2>max_Low) max_Low = max_2;    // Maximum_RWI_Low Index
           }
        }
      ExtABuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XPeriod,max_High,bar,true);
      ExtBBuffer[bar]=XMA2.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XPeriod,max_Low,bar,true);
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
