//+------------------------------------------------------------------+
//|                                                   iS7N_TREND.mq5 |
//|                                       Copyright 2010, SHOOTER777 |
//|                                                      s7n@mail.ru |
//+------------------------------------------------------------------+
#property copyright    "Copyright 2010, ARIES Software Corp."
#property link         "http://ariess.mp"
//#property version      "0.9"
#property description  "Copyright 2010, SHOOTER777"
#property description  "s7n@mail.ru"
//--- include libraries
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- custom settings
#property indicator_label1  "iTrend"
#property indicator_color1  DarkBlue, LightBlue
#property indicator_type1   DRAW_COLOR_LINE 
#property indicator_width1  2
//--- indicator input parameters 
input int Per=20;       // Period
input int iMax=200;     // Maximum number of bars to proceed
//--- indicator buffers
double dPlot[];
double dColor[];
//---  buffers for the calculation 
double dBuf_1[];
double dBuf_2[];
double dBuf_I[];
//--- handles
int ihMA_1;
int ihMA_2;
//--- global variables
int P0,P2,P4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetIndexBuffer(0,dPlot,INDICATOR_DATA);
   SetIndexBuffer(1,dColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,dBuf_I,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,dBuf_1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,dBuf_2,INDICATOR_CALCULATIONS);
//---
   ArraySetAsSeries(dPlot,true);
   ArraySetAsSeries(dColor,true);
   ArraySetAsSeries(dBuf_I,true);
   ArraySetAsSeries(dBuf_1,true);
   ArraySetAsSeries(dBuf_2,true);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits-1);
//--- calculating periods
   P0=Per;
   P2=Per/2;
   P4=(int)MathSqrt(Per);
//--- 
   ihMA_1  = iMA(Symbol(), Period(), P0 , 0, MODE_EMA, PRICE_CLOSE);
   ihMA_2  = iMA(Symbol(), Period(), P2 , 0, MODE_EMA, PRICE_CLOSE);
   if(ihMA_1<0 || ihMA_1<0) return(-1);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check if all data has been calculated
   if(BarsCalculated(ihMA_1)<rates_total) return(0);
   if(BarsCalculated(ihMA_2)<rates_total) return(0);
//--- perform calculations for the data, that haven't been calculated yet
   int to_copy=(int)MathMin(rates_total,rates_total-prev_calculated+1);
   if(prev_calculated<0 || prev_calculated>rates_total)to_copy=rates_total;
//--- the number of available bars should be 10 times greater than indicator period
   if(10*P0>rates_total)return(0);
   if(to_copy>iMax)to_copy=iMax;
//--- fixing the draw begin
   if(to_copy>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-(iMax-Per));
//--- calculation of preliminary data
   if(CopyBuffer(ihMA_1,0,0,to_copy,dBuf_1)!=to_copy)return(0);
   if(CopyBuffer(ihMA_2,0,0,to_copy,dBuf_2)!=to_copy)return(0);
   for(int i=0; i<to_copy; i++)
      dBuf_I[i]=2.0*dBuf_2[i]-dBuf_1[i];
//--- data calculations
   static int sum;
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,P4,dBuf_I,dPlot,sum);
//--- set color
   for(int i=0; i<to_copy;i++)
     {
      if(dPlot[i]>dPlot[i+1])
         dColor[i]=0;
      else
         dColor[i]=1;
     }
//--- return prev_calculated for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
