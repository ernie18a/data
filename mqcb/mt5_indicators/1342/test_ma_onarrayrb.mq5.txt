//+------------------------------------------------------------------+
//|                                            Test_MA_OnArrayRB.mq5 |
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
#property indicator_width1  1
//--- input parameters
input int            MAPeriod = 14;
input ENUM_MA_METHOD MAMethod = MODE_SMA;
//--- indicator buffers
double         MA_Buffer[];
//--- class with the indicator calculation methods
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
CMAOnRingBuffer ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of the moving average
   if(!ma.Init(MAPeriod,MAMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,MA_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,ma.Name());
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
//--- indicator calculation, based on the price timeseries
   ma.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-ma.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(MA_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;
//--- main loop:     
   for(int i=start;i<rates_total;i++)
      MA_Buffer[i]=ma[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+