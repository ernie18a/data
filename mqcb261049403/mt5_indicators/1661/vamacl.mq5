//+------------------------------------------------------------------+
//|                                                            vaMACl|
//|                                              Copyright 2013,  J.B|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, J.B"

#property version   "1.00"

#include <MovingAverages.mqh>

#property indicator_chart_window 
#property indicator_buffers 3 
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGray,clrRoyalBlue,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label1  "vaMACl"

input int vaMA_period=15;
input bool use_double_smooth=1;

double vaMA_buffer[],vaMA_Color_buffer[],EMA[];
//+------------------------------------------------------------------+
//| vaMACl initialization function                                   |
//+------------------------------------------------------------------+  
void OnInit()
  {
   SetIndexBuffer(0,vaMA_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,vaMA_Color_buffer,INDICATOR_DATA);
   SetIndexBuffer(2,EMA,INDICATOR_CALCULATIONS);
  }
//+------------------------------------------------------------------+
//| vaMACl iteration function                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {

   int first,bar;
   double vel,acc,aaa;

   ExponentialMAOnBuffer(rates_total,prev_calculated,begin,vaMA_period,price,EMA);                                   //Generate EMA from price

   if(rates_total<vaMA_period-1)return(0);                                                                           //
   if(prev_calculated==0)first=vaMA_period-1+begin;                                                                  //Checking the number of data for the cycle                                                                                      //
   else first=prev_calculated-1;                                                                                     //

   for(bar=first; bar<rates_total; bar++)                                                                            //Cycle by the bars array
     {
      vel = EMA[bar]-EMA[bar-vaMA_period/4];                                                                         //Increment between bars
      acc = EMA[bar]-2*EMA[bar-vaMA_period/4]+EMA[bar-vaMA_period/8];                                                //Increment of the increment between bars
      aaa = EMA[bar]-3*EMA[bar-vaMA_period/4]+3*EMA[bar-vaMA_period/8]-EMA[bar-vaMA_period/12];                      //Increment of the increment of the increment...                                                                                         
      vaMA_buffer[bar] = EMA[bar]+vel+acc/2+aaa/6;                                                                   //Alchemical mix
     }

   if(use_double_smooth)
      ExponentialMAOnBuffer(rates_total,prev_calculated,begin,vaMA_period/4,vaMA_buffer,vaMA_buffer);                 //Resmoothing of  EMA

   for(bar=first; bar<rates_total; bar++)                                                                             //
     {                                                                                                                //
      vaMA_Color_buffer[bar]=0;                                                                                       //Drawing the chart by the increment
      if(vaMA_buffer[bar-1]<vaMA_buffer[bar]) vaMA_Color_buffer[bar]=1;                                               //
      if(vaMA_buffer[bar-1]>vaMA_buffer[bar]) vaMA_Color_buffer[bar]=2;                                               //
     }                                                                                                                //

   return(rates_total);
  }
//+------------------------------------------------------------------+
