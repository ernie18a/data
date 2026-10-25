//+------------------------------------------------------------------+

//|                                                ExchangePrice.mq5 |
//|                                        Copyright 2013, papaklass |
//|                        https://login.mql5.com/ru/users/papaklass |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, papaklass"
#property link      "https://login.mql5.com/users/papaklass"
#property version   "1.00"
#define   line      DRAW_LINE
//---
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot short
#property indicator_label1  "short"
#property indicator_type1   line
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot long
#property indicator_label2  "long"
#property indicator_type2   line
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot level 0.0
#property indicator_level1       0.0
#property indicator_levelstyle   STYLE_DOT
#property indicator_levelcolor   clrPink
//--- input parameters
input int      shortPeriod =  96;      //to calculate the number of bars
input int      longPeriod  = 288;      //to calculate the number of bars
//--- indicator buffers
double         shortBuffer[];
double         longBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,shortBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,longBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME," ExchangePrice ");
   PlotIndexSetString(0,PLOT_LABEL,"short "+(string)shortPeriod+" bars ");
   PlotIndexSetString(1,PLOT_LABEL,"long "+(string)longPeriod+" bars ");
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of the price[] array
                 const int prev_calculated,  // processed bars at the previous call
                 const int begin,            // where significant data start from
                 const double& price[])      // an array for calculation
  {
   int i,limit;
   static int lastBar;
//--- check for rates
   if(rates_total<=longPeriod)
     {
      return(0);
     }
//---
   if(IsStopped()){ return(0); }
//---
   if(lastBar==rates_total){ return(rates_total); }
   lastBar=rates_total;
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ArrayInitialize(shortBuffer,0);
      ArrayInitialize(longBuffer,0);
      limit=longPeriod;
     }
   else
     {
      limit=prev_calculated-1;
     }
//--- the main loop of calculations
   for(i=limit; i<rates_total; i++)
     {
      shortBuffer[i] = price[i] - price[i - shortPeriod];
      longBuffer[i]  = price[i] - price[i - longPeriod];
     }
//--- OnCalculate done. Return new prev_calculated.
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
