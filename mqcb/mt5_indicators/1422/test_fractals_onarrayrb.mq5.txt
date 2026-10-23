//+------------------------------------------------------------------+
//|                                      Test_Fractals_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_color2  clrYellow
//--- input parameters
input int BarsRight = 2;       // Of bars on the right
input int BarsLeft  = 2;       // Of bars on the left
//--- indicator buffers 
double UpperBuffer[];
double LowerBuffer[];
//--- 10 pixels upper from high price
int    ext_arrow_shift=-10;
//--- class with the Fractals indicator calculation methods
#include <IncOnRingBuffer\CFractalsOnRingBuffer.mqh>
CFractalsOnRingBuffer fractals;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the Fractals indicator class instance:
   if(!fractals.Init(BarsRight,BarsLeft)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,"Upper "+fractals.Name()); 
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA); 
   PlotIndexSetString(1,PLOT_LABEL,"Lower "+fractals.Name()); 
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ext_arrow_shift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ext_arrow_shift);
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
   fractals.MainOnArray(rates_total,prev_calculated,high,low);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-fractals.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(UpperBuffer,EMPTY_VALUE);
      ArrayInitialize(LowerBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-BarsRight-1;    
//--- use the data from the "fractals" ring buffer,
//    for example, copy data to the indicator buffer:
   for(int i=start;i<rates_total-BarsRight && !IsStopped();i++)
     {
      UpperBuffer[i] = fractals.upper[rates_total-1-i]; // upper fractals
      LowerBuffer[i] = fractals.lower[rates_total-1-i]; // lower fractals
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+