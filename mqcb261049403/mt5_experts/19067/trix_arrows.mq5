//+------------------------------------------------------------------+
//|                                                  TRIX ARROWS.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.004"
#property description "Triple Exponential Average + signal period + arrows"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   4
//--- TRIX
#property indicator_label1  "TRIX"
#property indicator_color1  clrRed
#property indicator_width1  1
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
//--- Signal
#property indicator_label2  "Signal"
#property indicator_color2  clrBlue
#property indicator_width2  1
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
//--- Arrows
#property indicator_label3  "Arrows Up" 
#property indicator_color3  clrBlue
#property indicator_width3  1 
#property indicator_type3   DRAW_ARROW
#property indicator_label4  "Arrows Down" 
#property indicator_color4  clrRed 
#property indicator_width4  1 
#property indicator_type4   DRAW_ARROW
//---
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int               InpPeriodEMA   = 14;    // EMA period
input int               InpSignalPeriod= 8;     // Signal period
input ushort            InpCodeUp      = 233;   // Symbol code up 
input ushort            InpCodeDown    = 234;   // Symbol code down
//--- indicator buffers
double                  TRIX_Buffer[];
double                  Signal_Buffer[];
double                  Arrows_Buffer_Up[];
double                  Arrows_Buffer_Down[];

double                  EMA_TRIX[];
double                  SecondEMA_TRIX[];
double                  ThirdEMA_TRIX[];

double                  EMA_Signal[];
double                  SecondEMA_Signal[];
double                  ThirdEMA_Signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,TRIX_Buffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3*InpPeriodEMA-3);
//--- name for index label
   PlotIndexSetString(0,PLOT_LABEL,"TRIX("+string(InpPeriodEMA)+")");
   SetIndexBuffer(1,Signal_Buffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,3*InpSignalPeriod-3);
//--- name for index label
   PlotIndexSetString(1,PLOT_LABEL,"Signal("+string(InpSignalPeriod)+")");
   SetIndexBuffer(2,Arrows_Buffer_Up,INDICATOR_DATA);
//--- define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(2,PLOT_ARROW,InpCodeUp);
//--- set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,5);
//--- set as an empty value 0 
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   SetIndexBuffer(3,Arrows_Buffer_Down,INDICATOR_DATA);
//--- define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(3,PLOT_ARROW,InpCodeDown);
//--- set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,5);
//--- set as an empty value 0 
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---
   SetIndexBuffer(4,EMA_TRIX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,SecondEMA_TRIX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ThirdEMA_TRIX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,EMA_Signal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,SecondEMA_Signal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,ThirdEMA_Signal,INDICATOR_CALCULATIONS);
//--- name for indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX("+string(InpPeriodEMA)+
                      "), Signal("+string(InpSignalPeriod)+")");
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,5);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Triple Exponential Average                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check for data
   if(rates_total<3*InpPeriodEMA-3 || rates_total<3*InpSignalPeriod-3)
      return(0);
//---
   int limit_TRIX;
   int limit_Signal;
   int limit_Arrows;
   if(prev_calculated==0)
     {
      limit_TRIX=3*(InpPeriodEMA-1);
      for(int i=0;i<limit_TRIX;i++)
         TRIX_Buffer[i]=EMPTY_VALUE;

      limit_Signal=3*(InpSignalPeriod-1);
      for(int i=0;i<limit_Signal;i++)
         Signal_Buffer[i]=EMPTY_VALUE;

      limit_Arrows=0;
     }
   else
      limit_TRIX=limit_Signal=limit_Arrows=prev_calculated-1;
//--- calculate EMA
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriodEMA,price,EMA_TRIX);
//--- calculate EMA on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,InpPeriodEMA-1,InpPeriodEMA,EMA_TRIX,SecondEMA_TRIX);
//--- calculate EMA on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,2*InpPeriodEMA-2,InpPeriodEMA,SecondEMA_TRIX,ThirdEMA_TRIX);
//--- calculate TRIX
   for(int i=limit_TRIX;i<rates_total && !IsStopped();i++)
     {
      if(ThirdEMA_TRIX[i-1]!=0.0)
         TRIX_Buffer[i]=(ThirdEMA_TRIX[i]-ThirdEMA_TRIX[i-1])/ThirdEMA_TRIX[i-1];
      else
         TRIX_Buffer[i]=0.0;
     }
//--- calculate signal
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpSignalPeriod,price,EMA_Signal);
//--- calculate EMA on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,InpSignalPeriod-1,InpSignalPeriod,EMA_Signal,SecondEMA_Signal);
//--- calculate EMA on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,2*InpSignalPeriod-2,InpSignalPeriod,SecondEMA_Signal,ThirdEMA_Signal);
//--- calculate signal
   for(int i=limit_Signal;i<rates_total && !IsStopped();i++)
     {
      if(ThirdEMA_Signal[i-1]!=0.0)
         Signal_Buffer[i]=(ThirdEMA_Signal[i]-ThirdEMA_Signal[i-1])/ThirdEMA_Signal[i-1];
      else
         Signal_Buffer[i]=0.0;
     }
//--- calculate arrows
   for(int i=limit_Arrows;i<rates_total && !IsStopped();i++)
     {
      if(i>0)
        {
         if(Signal_Buffer[i-1]<TRIX_Buffer[i-1] && Signal_Buffer[i]>TRIX_Buffer[i])
            Arrows_Buffer_Up[i]=TRIX_Buffer[i];
         else
            Arrows_Buffer_Up[i]=0;

         if(Signal_Buffer[i-1]>TRIX_Buffer[i-1] && Signal_Buffer[i]<TRIX_Buffer[i])
            Arrows_Buffer_Down[i]=TRIX_Buffer[i];
         else
            Arrows_Buffer_Down[i]=0;
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
