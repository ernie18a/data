//+------------------------------------------------------------------+
//|                                                 CCI_DrawMode.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone"
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Standard Commodity Channel Index indicator with different drawing modes"
//---
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers       4
#property indicator_plots         2
//---
#property indicator_label1        "CCI Filling"
#property indicator_type2         DRAW_FILLING
#property indicator_color1        clrRed,clrGreen
#property indicator_width1        2
//---
#property indicator_label2        "CCI"
#property indicator_type2         DRAW_COLOR_HISTOGRAM
#property indicator_color2        clrGray,clrGreen,clrLimeGreen,clrRed,clrOrangeRed
#property indicator_width2        2
//---
#property indicator_level1       -100.0
#property indicator_level2        100.0
#property indicator_applied_price PRICE_TYPICAL
//---
enum DRAW_MODE
  {
   LINE,       // Line
   FILLING,    // Color fill
   HISTOGRAM   // Histogram
  };
//+------------------------------------------------------------------+
//| External parameters                                                |
//+------------------------------------------------------------------+
input int         InpCCIPeriod = 14;         // CCI period
input DRAW_MODE   InpDrawMode = HISTOGRAM;   // Drawing mode
input int         InpConfirmationBars = 3;   // Confirmation (number of bars)
//--- indicator buffers
double            ZeroLineBuffer[];
double            CCIBuffer[];
double            CCIColors[];
double            SMABuffer[];
//--- global variables
int               ExtCCIPeriod;
int               ExtConfirmationBars;
int               minRequiredBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   if(InpCCIPeriod<=0) 
     {
      ExtCCIPeriod = 14;
      printf("Invalid parameter value \"CCI period\": %d. The value to be used: %d.",
             InpCCIPeriod,ExtCCIPeriod);
        } else {
      ExtCCIPeriod=InpCCIPeriod;
     }
   minRequiredBars=2*ExtCCIPeriod-1;
   if(InpConfirmationBars<0) 
     {
      ExtConfirmationBars=3;
      printf("Invalid parameter value \"Confirmation\": %d. The value to be used: %d.",
             InpConfirmationBars,ExtConfirmationBars);
        } else {
      ExtConfirmationBars=InpConfirmationBars;
     }
//---
   SetIndexBuffer(0,ZeroLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CCIBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,CCIColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,SMABuffer,INDICATOR_CALCULATIONS);
//---
   for(int i=0; i<3; i++) 
     {
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,minRequiredBars);
     }
//---
   if(InpDrawMode==LINE) 
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
        } else if(InpDrawMode==FILLING) {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_FILLING);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
        } else if(InpDrawMode==HISTOGRAM) {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
     }
//---
   string shortname;
   StringConcatenate(shortname,"CCI (",ExtCCIPeriod,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
//---
   int startBar,counter;
   double multiplier=0.015/ExtCCIPeriod;
   static int counter_;
//--- checking for the sufficiency of data for calculation
   minRequiredBars+=begin;
   if(rates_total<minRequiredBars) 
     {
      Print("Insufficient data for calculation: ",rates_total," min: ",minRequiredBars," begin: ",begin);

      return(0);
     }
//--- correct draw begin
   if(begin>0) 
     {
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,minRequiredBars);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,minRequiredBars);
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) 
     {
      startBar = ExtCCIPeriod - 1 + begin;
      counter_ = 0;
        } else {
      startBar=prev_calculated-1;
     }
//--- main cycle
   for(int bar=startBar; bar<rates_total && !IsStopped(); bar++) 
     {
      double valueD,valueM;

      //--- SMA on price buffer 
      SMABuffer[bar]=SimpleMA(bar,ExtCCIPeriod,price);
      //--- calculate D
      valueD=0.0;
      for(int shift=0; shift<ExtCCIPeriod; shift++) 
        {
         valueD+=MathAbs(price[bar-shift]-SMABuffer[bar]);
        }
      valueD*=multiplier;
      //--- calculate M
      valueM=price[bar]-SMABuffer[bar];
      //--- calculate CCI
      if(valueD!=0.0) 
        {
         CCIBuffer[bar]=valueM/valueD;
           } else {
         CCIBuffer[bar]=0.0;
        }
      ZeroLineBuffer[bar]=0.0;
     }
//---
   if(InpDrawMode==HISTOGRAM) 
     {
      counter=counter_;
      for(int bar=startBar; bar<rates_total && !IsStopped(); bar++) 
        {
         int prevBar=bar-1;

         if(rates_total!=prev_calculated && bar==rates_total-1) 
           {
            counter_=counter;
           }
         if(CCIBuffer[bar]>0.0) 
           {
            CCIColors[bar]=1;
            if(CCIBuffer[bar]<=CCIBuffer[prevBar]) 
              {
               CCIColors[bar] = 2;
              }
              } else {
            CCIColors[bar]=3;
            if(CCIBuffer[bar]>=CCIBuffer[prevBar]) 
              {
               CCIColors[bar] = 4;
              }
           }
         if(CCIBuffer[bar] *CCIBuffer[bar-1]<0) 
           {
            counter=0;
           }
         if(counter<ExtConfirmationBars) 
           {
            counter+=1;
            CCIColors[bar]=0;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
