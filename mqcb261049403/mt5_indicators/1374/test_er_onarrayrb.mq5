//+------------------------------------------------------------------+
//|                                            Test_ER_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int      InpPeriodER=34;      // ER period
//--- indicator buffers 
double         ERBuffer[]; 
//--- class with the ER indicator calculation methods
#include <IncOnRingBuffer\CEROnRingBuffer.mqh>
CEROnRingBuffer er;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the ER indicator class instance:
   if(!er.Init(InpPeriodER)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,ERBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,er.Name()); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const int begin, 
                const double &price[]) 
  {
//--- indicator calculation, based on the price timeseries:
   er.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-er.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(ERBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "er" ring buffers,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total && !IsStopped();i++)
      ERBuffer[i] = er[rates_total-1-i];          // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+