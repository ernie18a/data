//+------------------------------------------------------------------+
//|                                      Test_Fractals_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_color2  clrYellow
#property indicator_color3  clrRed
#property indicator_color4  clrRed
//--- input parameters
input int BarsRight = 2;       // Of bars on the right
input int BarsLeft  = 2;       // Of bars on the left
//--- indicator buffers
double UpperBuffer[];
double LowerBuffer[];
double UpperRingBuffer[];
double LowerRingBuffer[];
//--- 10 pixels upper from high price
int    ext_arrow_shift=-10;
//---
int    ext_begin=BarsLeft+BarsRight+1;
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
   SetIndexBuffer(2,UpperRingBuffer,INDICATOR_DATA); 
   PlotIndexSetString(0,PLOT_LABEL,"UpperRB "+fractals.Name()); 
   SetIndexBuffer(3,LowerRingBuffer,INDICATOR_DATA); 
   PlotIndexSetString(1,PLOT_LABEL,"LowerRB "+fractals.Name()); 
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
   PlotIndexSetInteger(2,PLOT_ARROW,217);
   PlotIndexSetInteger(3,PLOT_ARROW,218);
//---- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ext_arrow_shift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ext_arrow_shift);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,2*ext_arrow_shift);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-2*ext_arrow_shift);
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
      start=BarsLeft+BarsRight+1;
      start1=rates_total-fractals.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start+fractals.BarsRequired());
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start+fractals.BarsRequired());
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start1);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(UpperBuffer,EMPTY_VALUE);
      ArrayInitialize(LowerBuffer,EMPTY_VALUE);
      ArrayInitialize(UpperRingBuffer,EMPTY_VALUE);
      ArrayInitialize(LowerRingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else
     {
      start =prev_calculated-1;
      start1=prev_calculated-1-BarsRight;
     }
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total && !IsStopped();i++)
     {
      UpperBuffer[i-BarsRight]=fractals.MainOnHigh(rates_total,prev_calculated,ext_begin,high[i],i);
      LowerBuffer[i-BarsRight]=fractals.MainOnLow (rates_total,prev_calculated,ext_begin,low[i], i);
     }
//--- use the values ??of the ring buffer to draw another indicator:     
   for(int i=start1;i<rates_total-BarsRight && !IsStopped();i++)
     {
      UpperRingBuffer[i]=fractals.upper[rates_total-1-i];
      LowerRingBuffer[i]=fractals.lower[rates_total-1-i];
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+