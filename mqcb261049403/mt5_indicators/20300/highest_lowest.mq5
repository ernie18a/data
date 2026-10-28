//+------------------------------------------------------------------+
//|                                               Highest Lowest.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 2 
#property indicator_plots   2 
//--- plot Arrows 
#property indicator_label1  "Highest" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrBlue 
#property indicator_width2  1 
#property indicator_label2  "Lowest" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrRed 
#property indicator_width2  1 
//--- input parameters 
input ushort   InpHighestCode = 159;      // Symbol code to draw Highest
input ushort   InpLowestCode  = 159;      // Symbol code to draw Lowest
//--- An indicator buffers for the plot 
double         HighestBuffer[];
double         LowestBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
//--- Define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,InpHighestCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpLowestCode);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-5);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,5);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
/*
   int bar_0=0;
   int bar_rates_total_minus_1=rates_total-1;
   Comment("prev_calculated=",prev_calculated,"\n",
           "time[",bar_0,"]=",time[bar_0],"\n",
           "time[",bar_rates_total_minus_1,"]=",time[bar_rates_total_minus_1]);
*/
//---
   if(rates_total<10)
      return(0);
//---
   int limit=prev_calculated-2;
   if(prev_calculated==0)
     {
      ArrayInitialize(HighestBuffer,EMPTY_VALUE);
      ArrayInitialize(LowestBuffer,EMPTY_VALUE);
      limit=1;
     }
   if(rates_total!=prev_calculated)
      int d=0;
//---
   for(int i=limit;i<rates_total-1;i++)
     {
      if(high[i-1]<high[i] && high[i]>high[i+1])
        {
         int d=0;
         HighestBuffer[i]=high[i];
        }
      else
         HighestBuffer[i]=EMPTY_VALUE;
      //---
      if(low[i-1]>low[i] && low[i]<low[i+1])
        {
         int d=0;
         LowestBuffer[i]=low[i];
        }
      else
         LowestBuffer[i]=EMPTY_VALUE;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
