//+------------------------------------------------------------------+
//|                                           Test_MFI_OnArrayRB.mq5 |
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
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int                 MFIPeriod     = 14;            // Period
input ENUM_MA_METHOD      MFIMethod     = MODE_SMA;      // Method
input ENUM_APPLIED_PRICE  MFIPriceType  = PRICE_TYPICAL; // Price
input ENUM_APPLIED_VOLUME MFIVolumeType = VOLUME_TICK;   // Volumes
//--- indicator buffers 
double MFI_Buffer[]; 
//--- class with the MFI indicator calculation methods
#include <IncOnRingBuffer\CMFIOnRingBuffer.mqh>
CMFIOnRingBuffer mfi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the MFI indicator class instance:
   if(!mfi.Init(MFIPeriod,MFIMethod,MFIPriceType,MFIVolumeType)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,MFI_Buffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,mfi.Name()); 
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
   mfi.MainOnArray(rates_total,prev_calculated,open,high,low,close,tick_volume,volume);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-mfi.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(MFI_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "mfi" ring buffers,
//    for example, copy data to the indicator buffer:
   for(int i=start;i<rates_total && !IsStopped();i++)
      MFI_Buffer[i] = mfi[rates_total-1-i]; // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+