//+------------------------------------------------------------------+
//|                                           Test_RSI_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 0 
#property indicator_maximum 100 
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int            RSIPeriod   =  14; 
input ENUM_MA_METHOD RSIMethod   =  MODE_SMMA; 
//--- indicator buffers 
double RSI_Buffer[]; 
//--- class with the RSI indicator calculation methods
#include <IncOnRingBuffer\CRSIOnRingBuffer.mqh>
CRSIOnRingBuffer rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the RSI indicator class instance:
   if(!rsi.Init(RSIPeriod,RSIMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,RSI_Buffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,rsi.Name()); 
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
   rsi.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-rsi.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(RSI_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "rsi" ring buffers,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total && !IsStopped();i++)
      RSI_Buffer[i] = rsi[rates_total-1-i];          // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+