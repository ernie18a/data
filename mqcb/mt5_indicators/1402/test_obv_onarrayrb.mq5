//+------------------------------------------------------------------+
//|                                           Test_OBV_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//--- indicator settings
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
input ENUM_APPLIED_VOLUME  OBVVolume = VOLUME_TICK; // Volume type
input int                  OBVPeriod = 0;           // Period
//--- indicator buffers 
double OBV_Buffer[]; 
//--- class with the OBV indicator calculation methods
#include <IncOnRingBuffer\COBVOnRingBuffer.mqh>
COBVOnRingBuffer obv;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the OBV indicator class instance:
   if(!obv.Init(OBVPeriod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator buffers mapping
   SetIndexBuffer(0,OBV_Buffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,obv.Name()); 
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
//--- indicator calculation, based on the timeseries
   if(OBVVolume==VOLUME_TICK)
      obv.MainOnArray(rates_total,prev_calculated,close,tick_volume);
   else
      obv.MainOnArray(rates_total,prev_calculated,close,volume);   
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-obv.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(OBV_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "obv" ring buffer,
//    for example, copy data to the indicator buffer:
   for(int i=start;i<rates_total && !IsStopped();i++)
      OBV_Buffer[i] = obv[rates_total-1-i]; // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+