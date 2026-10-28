//+------------------------------------------------------------------+
//|                                          Test_MACD_OnArrayRB.mq5 |
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
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrRed 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1 
//--- input parameters 
input int             MACDFastPeriod   = 12; 
input int             MACDSlowPeriod   = 26; 
input int             MACDSignalPeriod = 9; 
input ENUM_MA_METHOD  MACDFastMetod    = MODE_EMA; 
input ENUM_MA_METHOD  MACDSlowMethod   = MODE_EMA; 
input ENUM_MA_METHOD  MACDSignalMethod = MODE_SMA; 
//--- indicator buffers 
double         MainBuffer[]; 
double         SignalBuffer[]; 
//--- class with the MACD indicator calculation methods
#include <IncOnRingBuffer\CMACDOnRingBuffer.mqh>
CMACDOnRingBuffer macd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the MACD indicator class instance:
   if(!macd.Init(MACDFastPeriod,MACDSlowPeriod,MACDSignalPeriod,MACDFastMetod,MACDSlowMethod,MACDSignalMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA); 
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,macd.NameMain()); 
   PlotIndexSetString(1,PLOT_LABEL,macd.NameSignal()); 
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
   macd.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-macd.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(MainBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "macd" ring buffers,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total;i++)
     {
      MainBuffer[i]   = macd[rates_total-1-i];          // indicator histogram
      SignalBuffer[i] = macd.signal[rates_total-1-i];   // indicator signal line
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+