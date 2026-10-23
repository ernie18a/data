//+------------------------------------------------------------------+
//|                                          Test_OsMA_OnValueRB.mq5 |
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
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrAquamarine 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- plot Label2 
#property indicator_label2  "Label2" 
#property indicator_type2   DRAW_HISTOGRAM 
#property indicator_color2  clrMagenta 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1 

//--- input parameters 
input int             OsMAFastPeriod   = 12; 
input int             OsMASlowPeriod   = 26; 
input int             OsMASignalPeriod = 9; 
input ENUM_MA_METHOD  OsMAFastMetod    = MODE_EMA; 
input ENUM_MA_METHOD  OsMASlowMethod   = MODE_EMA; 
input ENUM_MA_METHOD  OsMASignalMethod = MODE_SMA; 
//--- indicator buffers 
double OsMABuffer[]; 
double OsMARingBuffer[]; 
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
   SetIndexBuffer(1,OsMARingBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,osma.Name()); 
   PlotIndexSetString(1,PLOT_LABEL,"RB "+osma.Name()); 
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
      start1=rates_total-osma.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(OsMABuffer,EMPTY_VALUE);
      ArrayInitialize(OsMARingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;    
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total;i++)
      OsMABuffer[i]=osma.MainOnValue(rates_total,prev_calculated,begin,price[i],i); // indicator histogram
//--- use the data from the "adxw" ring buffer,
//    copy data to the indicator buffers:
   for(int i=start1;i<rates_total;i++)
      OsMARingBuffer[i]=osma[rates_total-1-i]; // second indicator histogram
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+