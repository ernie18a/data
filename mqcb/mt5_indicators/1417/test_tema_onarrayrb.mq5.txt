//+------------------------------------------------------------------+
//|                                          Test_TEMA_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int            TEMAPeriod = 12;       // Period
input ENUM_MA_METHOD TEMAMethod = MODE_EMA; // Method
//--- indicator buffers 
double TEMA_Buffer[]; 
//--- class with the TEMA indicator calculation methods
#include <IncOnRingBuffer\CTEMAOnRingBuffer.mqh>
CTEMAOnRingBuffer tema;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the TEMA indicator class instance:
   if(!tema.Init(TEMAPeriod,TEMAMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,TEMA_Buffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,tema.Name()); 
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
//--- indicator calculation, based on the timeseries
   tema.MainOnArray(rates_total,prev_calculated,price);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-tema.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(TEMA_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "tema" ring buffer,
//    for example, copy data to the indicator buffer:
   for(int i=start;i<rates_total && !IsStopped();i++)
      TEMA_Buffer[i] = tema[rates_total-1-i]; // indicator line
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+