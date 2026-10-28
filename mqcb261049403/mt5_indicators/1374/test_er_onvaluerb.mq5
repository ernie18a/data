//+------------------------------------------------------------------+
//|                                            Test_ER_OnValueRB.mq5 |
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
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_width2  1

//--- input parameters
input int      InpPeriodER=34;      // ER period
//--- indicator buffers
double         ER_Buffer[];
double         ER_RingBuffer[];
//--- class with the ER indicator calculation methods
#include <IncOnRingBuffer\CEROnRingBuffer.mqh>
CEROnRingBuffer er;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the ER indicator class instances:
   if(!er.Init(InpPeriodER)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,ER_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,er.Name());
   SetIndexBuffer(1,ER_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"RB "+er.Name());
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
//--- first calculation:
   int start=0, start1=0;
   if(prev_calculated==0)
     {
      start1=rates_total-er.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1+er.BarsRequired());
      ArrayInitialize(ER_Buffer,EMPTY_VALUE);
      ArrayInitialize(ER_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total && !IsStopped();i++)
      ER_Buffer[i]=er.MainOnValue(rates_total,prev_calculated,begin,price[i],i);
//--- use the values ??of the ring buffer to draw another indicator line:     
   for(int i=start1;i<rates_total && !IsStopped();i++)
      ER_RingBuffer[i]=er[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+