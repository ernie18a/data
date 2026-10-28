//+------------------------------------------------------------------+
//|                                      Test_Momentum_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//---- indicator settings
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
input int MomentumPeriod = 14; // Period
//--- indicator buffers
double Momentum_Buffer[];
double Momentum_RingBuffer[];
//--- class with the Momentum indicator calculation methods
#include <IncOnRingBuffer\CMomentumOnRingBuffer.mqh>
CMomentumOnRingBuffer momentum;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the Momentum indicator class instances:
   if(!momentum.Init(MomentumPeriod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,Momentum_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,momentum.Name());
   SetIndexBuffer(1,Momentum_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"RB "+momentum.Name());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of the array price[]
                 const int prev_calculated,  // number of bars processed at the previous call
                 const int begin,            // where the significant data start from
                 const double& price[])      // array for calculation
  {
//--- first calculation:
   int start=0, start1=0;
   if(prev_calculated==0)
     {
      start1=rates_total-momentum.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start+momentum.BarsRequired());
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(Momentum_Buffer,EMPTY_VALUE);
      ArrayInitialize(Momentum_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total && !IsStopped();i++)
      Momentum_Buffer[i]=momentum.MainOnValue(rates_total,prev_calculated,begin,price[i],i);
//--- use the values ??of the ring buffer to draw another indicator line:     
   for(int i=start1;i<rates_total && !IsStopped();i++)
      Momentum_RingBuffer[i]=momentum[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+