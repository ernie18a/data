//+------------------------------------------------------------------+
//|                                    Test_Stochastic_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- plot Label2
#property indicator_label2  "Label2" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrBlue 
#property indicator_style2  STYLE_DOT 
#property indicator_width2  1 
//--- input parameters 
input int            STPeriodK   =  5; 
input int            STPeriodD   =  3; 
input int            STPeriodS   =  3; 
input ENUM_MA_METHOD STMethod    =  MODE_SMA; 
//--- indicator buffers 
double MainBuffer[]; 
double SignalBuffer[]; 
//--- class with the Stochastic indicator calculation methods
#include <IncOnRingBuffer\CStochasticOnRingBuffer.mqh>
CStochasticOnRingBuffer st;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the Stochastic indicator class instance:
   if(!st.Init(STPeriodK,STPeriodD,STPeriodS,STMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,st.Name()); 
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA); 
   PlotIndexSetString(1,PLOT_LABEL,st.NameSignal()); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//--- indicator calculation, based on the price timeseries
   st.MainOnArray(rates_total,prev_calculated,high,low,close);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-st.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(MainBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "st" ring buffers,
//    for example, copy data to the indicator buffers:
   for(int i=start;i<rates_total && !IsStopped();i++)
     {
      MainBuffer[i]   = st[rates_total-1-i];        // indicator main line
      SignalBuffer[i] = st.signal[rates_total-1-i]; // indicator signal line
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+