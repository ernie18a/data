//+------------------------------------------------------------------+
//|                                           Test_MFI_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//---- indicator settings
#property indicator_separate_window
#property indicator_minimum    0 
#property indicator_maximum    100 
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor Silver
#property indicator_levelstyle 2
#property indicator_levelwidth 1
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
input int                 MFIPeriod     = 14;            // Period
input ENUM_MA_METHOD      MFIMethod     = MODE_SMA;      // Method
input ENUM_APPLIED_PRICE  MFIPriceType  = PRICE_TYPICAL; // Price
input ENUM_APPLIED_VOLUME MFIVolumeType = VOLUME_TICK;   // Volumes
//--- indicator buffers
double MFI_Buffer[];
double MFI_RingBuffer[];
//--- class with the MFI indicator calculation methods
#include <IncOnRingBuffer\CMFIOnRingBuffer.mqh>
CMFIOnRingBuffer mfi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the MFI indicator class instances:
   if(!mfi.Init(MFIPeriod,MFIMethod,MFIPriceType,MFIVolumeType)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,MFI_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,mfi.Name());
   SetIndexBuffer(1,MFI_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"RB "+mfi.Name());
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
      start1=rates_total-mfi.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start+mfi.BarsRequired());
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(MFI_Buffer,EMPTY_VALUE);
      ArrayInitialize(MFI_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total && !IsStopped();i++)
      MFI_Buffer[i]=mfi.MainOnValue(rates_total,prev_calculated,begin,open[i],high[i],low[i],close[i],tick_volume[i],volume[i],i);
//--- use the values ??of the ring buffer to draw another indicator line:     
   for(int i=start1;i<rates_total && !IsStopped();i++)
      MFI_RingBuffer[i]=mfi[rates_total-1-i];
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+