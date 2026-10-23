//+------------------------------------------------------------------+
//|                                          Test_OsMA_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrAquamarine 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters 
input int             OsMAFastPeriod   = 12; 
input int             OsMASlowPeriod   = 26; 
input int             OsMASignalPeriod = 9; 
input ENUM_MA_METHOD  OsMAFastMetod    = MODE_EMA; 
input ENUM_MA_METHOD  OsMASlowMethod   = MODE_EMA; 
input ENUM_MA_METHOD  OsMASignalMethod = MODE_SMA; 
//--- indicator buffers 
double         OsMABuffer[]; 
//--- class with the OsMA indicator calculation methods
#include <IncOnRingBuffer\COsMAOnRingBuffer.mqh>
COsMAOnRingBuffer osma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the OsMA indicator class instance:
   if(!osma.Init(OsMAFastPeriod,OsMASlowPeriod,OsMASignalPeriod,OsMAFastMetod,OsMASlowMethod,OsMASignalMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);
//--- indicator buffers mapping
   SetIndexBuffer(0,OsMABuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,osma.Name()); 
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
   osma.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-osma.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(OsMABuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "osma" ring buffers,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total;i++)
      OsMABuffer[i]= osma[rates_total-1-i];          // indicator histogram
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+