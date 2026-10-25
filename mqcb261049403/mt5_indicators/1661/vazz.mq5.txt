//+------------------------------------------------------------------+
//|                                                              vaZZ|
//|                                              Copyright 2013,  J.B|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, J.B"

#property version   "1.00"

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_color1  clrBlack,clrCyan,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label1  "vaZZ"

input int vaMA_period=15;
input bool use_double_smooth=1;

double vaMA_buffer[],ZZhigh_buffer[],ZZlow_buffer[],ZZColor_buffer[],EMA[];
//+------------------------------------------------------------------+
//| vaZZ initialization function                                     |
//+------------------------------------------------------------------+  
void OnInit()
  {
   SetIndexBuffer(0,ZZhigh_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZZlow_buffer,INDICATOR_DATA);
   SetIndexBuffer(2,ZZColor_buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,EMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,vaMA_buffer,INDICATOR_CALCULATIONS);
  }
//+------------------------------------------------------------------+
//| vaZZ iteration function                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   int first,bar;
   double vel,acc,aaa;

   ExponentialMAOnBuffer(rates_total,prev_calculated,begin,vaMA_period,price,EMA);

   if(rates_total<vaMA_period-1)return(0);
   if(prev_calculated==0)first=vaMA_period-1+begin;
   else first=prev_calculated-1;

   for(bar=first; bar<rates_total; bar++)
     {
      vel = EMA[bar]-EMA[bar-vaMA_period/4];
      acc = EMA[bar]-2*EMA[bar-vaMA_period/4]+EMA[bar-vaMA_period/8];
      aaa = EMA[bar]-3*EMA[bar-vaMA_period/4]+3*EMA[bar-vaMA_period/8]-EMA[bar-vaMA_period/12];                                                                                        
      vaMA_buffer[bar] = EMA[bar]+vel+acc/2+aaa/6;
     }

   if(use_double_smooth)
      ExponentialMAOnBuffer(rates_total,prev_calculated,begin,vaMA_period/4,vaMA_buffer,vaMA_buffer);
      
   for(bar=first; bar<rates_total; bar++)
     {
      ZZColor_buffer[bar]=0;
      ZZhigh_buffer[bar]=EMPTY_VALUE;
      ZZlow_buffer[bar]=EMPTY_VALUE;
      
      if(vaMA_buffer[bar-1]<vaMA_buffer[bar]) ZZColor_buffer[bar]=1;
      if(vaMA_buffer[bar-1]>vaMA_buffer[bar]) ZZColor_buffer[bar]=2;
      
      if(ZZColor_buffer[bar]-ZZColor_buffer[bar-1]==1)
      ZZhigh_buffer[bar-1]=price[bar-1];
        
      if(ZZColor_buffer[bar]-ZZColor_buffer[bar-1]==-1)
      ZZlow_buffer[bar-1]=price[bar-1]; 
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
