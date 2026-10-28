//+------------------------------------------------------------------+
//|                                           Test_ATR_OnValueRB.mq5 |
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
#property indicator_label2  "ATR RB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_width2  1

//--- input parameters
input int            MAPeriod = 14;
input ENUM_MA_METHOD MAMethod = MODE_SMA;
//--- indicator buffers
double         ATR_Buffer[];
double         ATR_RingBuffer[];
//--- class with the ATR indicator calculation methods
#include <IncOnRingBuffer\CATROnRingBuffer.mqh>
CATROnRingBuffer atr, atr_rb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the ATR indicator class instances:
   if(!atr.Init(MAPeriod,MAMethod))    return(INIT_FAILED);
   if(!atr_rb.Init(MAPeriod,MAMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,ATR_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,atr.Name());
   SetIndexBuffer(1,ATR_RingBuffer,INDICATOR_DATA);
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
//--- first calculation:
   int start=0, begin=0, start1=0;
   if(prev_calculated==0)
     {
      start=begin=0;
      start1=rates_total-atr.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1+atr.BarsRequired());
      ArrayInitialize(ATR_Buffer,EMPTY_VALUE);
      ArrayInitialize(ATR_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total;i++)
      ATR_Buffer[i]=atr.MainOnValue(rates_total,prev_calculated,begin,high[i],low[i],close[i],i);
//--- use the values ??of the ring buffer to draw another indicator line:     
   for(int i=start1;i<rates_total;i++)
      ATR_RingBuffer[i]=atr[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+