//+------------------------------------------------------------------+
//|                                           Test_OBV_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//--- indicator settings
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
input ENUM_APPLIED_VOLUME  OBVVolume = VOLUME_TICK; // Volume type
input int                  OBVPeriod = 0;           // Period
//--- indicator buffers
double OBV_Buffer[];
double OBV_RingBuffer[];
//--- class with the OBV indicator calculation methods
#include <IncOnRingBuffer\COBVOnRingBuffer.mqh>
COBVOnRingBuffer obv;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the OBV indicator class instances:
   if(!obv.Init(OBVPeriod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator buffers mapping
   SetIndexBuffer(0,OBV_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,obv.Name());
   SetIndexBuffer(1,OBV_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"RB "+obv.Name());
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
      start1=rates_total-obv.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start+obv.BarsRequired());
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(OBV_Buffer,EMPTY_VALUE);
      ArrayInitialize(OBV_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- calculate and draw the indicator:     
   if(OBVVolume==VOLUME_TICK)
     {
      for(int i=start;i<rates_total && !IsStopped();i++)
        OBV_Buffer[i]=obv.MainOnValue(rates_total,prev_calculated,begin,close[i],tick_volume[i],i);
     }
   else
     {
      for(int i=start;i<rates_total && !IsStopped();i++)
        OBV_Buffer[i]=obv.MainOnValue(rates_total,prev_calculated,begin,close[i],volume[i],i);

     }
//--- use the values ??of the ring buffer to draw another indicator line:     
   for(int i=start1;i<rates_total && !IsStopped();i++)
      OBV_RingBuffer[i]=obv[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+