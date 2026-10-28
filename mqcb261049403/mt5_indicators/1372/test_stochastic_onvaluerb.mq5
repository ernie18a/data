//+------------------------------------------------------------------+
//|                                    Test_Stochastic_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4

//--- plot Label1 
#property indicator_label1  "Label1" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- plot Label2
#property indicator_label2  "Label2" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrBlue 
#property indicator_style2  STYLE_DOT 
#property indicator_width2  1 
//--- plot Label3 
#property indicator_label3  "Label3" 
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrGreen 
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1 
//--- plot Label4
#property indicator_label4  "Label4" 
#property indicator_type4   DRAW_LINE 
#property indicator_color4  clrGray 
#property indicator_style4  STYLE_DOT 
#property indicator_width4  1 
//--- input parameters 
input int            STPeriodK   =  5; 
input int            STPeriodD   =  3; 
input int            STPeriodS   =  3; 
input ENUM_MA_METHOD STMethod    =  MODE_SMA; 
//--- indicator buffers 
double MainBuffer[]; 
double SignalBuffer[]; 
double MainRingBuffer[]; 
double SignalRingBuffer[]; 
//--- class with the Stochastic indicator calculation methods
#include <IncOnRingBuffer\CStochasticOnRingBuffer.mqh>
CStochasticOnRingBuffer st;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the Stochastic indicator class instance:
   if(!st.Init(STPeriodK,STPeriodD,STPeriodS,STMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA); 
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA); 
   SetIndexBuffer(2,MainRingBuffer,INDICATOR_DATA); 
   SetIndexBuffer(3,SignalRingBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,st.Name()); 
   PlotIndexSetString(1,PLOT_LABEL,st.NameSignal()); 
   PlotIndexSetString(2,PLOT_LABEL,"RB "+st.Name()); 
   PlotIndexSetString(3,PLOT_LABEL,"RB "+st.NameSignal()); 
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
   int start=0, start1=0;
   if(prev_calculated==0)
     {
      start1=rates_total-st.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start1);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(MainBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalBuffer,EMPTY_VALUE);
      ArrayInitialize(MainRingBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalRingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;    
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total && !IsStopped();i++)
     {
      MainBuffer[i]   = st.MainOnValue(rates_total,prev_calculated,0,high[i],low[i],close[i],i);   // indicator main line
      SignalBuffer[i] = st.signal.Last();                                                          // indicator signal line
     }
//--- use the data from the "st" ring buffers,
//    for example, copy data to the indicator buffers:
   for(int i=start1;i<rates_total && !IsStopped();i++)
     {
      MainRingBuffer[i]  = st[rates_total-1-i];          // indicator main line
      SignalRingBuffer[i]= st.signal[rates_total-1-i];   // indicator signal line
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+