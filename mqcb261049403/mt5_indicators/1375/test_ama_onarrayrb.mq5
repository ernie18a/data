//+------------------------------------------------------------------+
//|                                           Test_AMA_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int      InpPeriodAMA=10;      // AMA period
input int      InpFastPeriodEMA=2;   // Fast EMA period
input int      InpSlowPeriodEMA=30;  // Slow EMA period
//--- indicator buffers 
double         Buffer[]; 
//--- class with the AMA indicator calculation methods
#include <IncOnRingBuffer\CAMAOnRingBuffer.mqh>
CAMAOnRingBuffer ama;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the AMA indicator class instance:
   if(!ama.Init(InpPeriodAMA,InpFastPeriodEMA,InpSlowPeriodEMA)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,ama.Name()); 
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
   ama.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-ama.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "ama" ring buffers,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total && !IsStopped();i++)
      Buffer[i] = ama[rates_total-1-i];          // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+