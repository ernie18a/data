//+------------------------------------------------------------------+
//|                                            Test_MA_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "MA RB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_width2  1
//--- input parameters
input int            MAPeriod = 14;
input ENUM_MA_METHOD MAMethod = MODE_SMA;
//--- indicator buffers
double         MA_Buffer[];
double         MA_RingBuffer[];
//--- class with the indicator calculation methods
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
CMAOnRingBuffer ma, ma_rb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of the moving average
   if(!ma.Init(MAPeriod,MAMethod))    return(INIT_FAILED);
   if(!ma_rb.Init(MAPeriod,MAMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,MA_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,ma.Name());
   SetIndexBuffer(1,MA_RingBuffer,INDICATOR_DATA);
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
   int start=0, start1=0, begin1=0;
   if(prev_calculated==0)
     {
      start=begin;
      begin1=start1=rates_total-ma.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1+ma.BarsRequired());
      ArrayInitialize(MA_Buffer,EMPTY_VALUE);
      ArrayInitialize(MA_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- MA calculation, based on the price timeseries
   for(int i=start;i<rates_total;i++)
      MA_Buffer[i]=ma.MainOnValue(rates_total,prev_calculated,begin,price[i],i);
//--- MA calculation, based on the ring buffer of the previous calculation     
   for(int i=start1;i<rates_total;i++)
      MA_RingBuffer[i]=ma_rb.MainOnValue(rates_total,prev_calculated,begin1,ma[rates_total-1-i],i);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+