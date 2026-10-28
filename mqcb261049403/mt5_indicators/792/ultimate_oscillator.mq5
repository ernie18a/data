//+------------------------------------------------------------------+
//|                                          Ultimate_Oscillator.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"
#property description "Ultimate Oscillator"
//---- version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window 
//---- number of buffers used
#property indicator_buffers 1 
//---- number of plots used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing settings                  |
//+----------------------------------------------+
//---- drawing type - line
#property indicator_type1   DRAW_LINE
//---- line color - blue
#property indicator_color1 Blue
//---- line style - solid line
#property indicator_style1  STYLE_SOLID
//---- line width - 1
#property indicator_width1  2
//---- line label
#property indicator_label1  "Ultimate Oscillator"
//+----------------------------------------------+
//| Plot settings for horizontal levels          |
//+----------------------------------------------+
#property indicator_level1 70
#property indicator_level2 50
#property indicator_level3 30
#property indicator_levelcolor DarkOrange
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  constants                                   |
//+----------------------------------------------+
#define RESET 0 // RESET
//+----------------------------------------------+
//| Classes for averaging                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- declaration of CXMA class variables, declared in SmoothAlgorithms.mqh
CXMA FXMA,MXMA,SXMA;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint fastperiod=7;
input uint middleperiod=14;
input uint slowperiod=28;
input uint fastK=4;
input uint middleK=2;
input uint slowK= 1;
input int  Shift=0;   // Horizontal shift (in bars)
//+----------------------------------------------+
//---- declaration of dynamic array, that will be used as indicator buffer
double IndBuffer[];
//---- delcaraton of integer type variables
int min_rates_total,divider;
//---- declaration of variables, used for indicator handles
int FATR_Handle,MATR_Handle,SATR_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- min rates
   min_rates_total=int(MathMax(MathMax(fastperiod,middleperiod),slowperiod)+fastK+middleK+slowK);
   divider = int(fastK + middleK + slowK);
   
//---- get handle of ATR indicator
   FATR_Handle=iATR(NULL,0,fastperiod);
   if(FATR_Handle==INVALID_HANDLE)Print(" Error in creation of ATR indicator");
   
//---- get handle of ATR indicator
   MATR_Handle=iATR(NULL,0,middleperiod);
   if(MATR_Handle==INVALID_HANDLE)Print(" Error in creation of ATR indicator");
   
//---- get handle of ATR indicator
   SATR_Handle=iATR(NULL,0,slowperiod);
   if(SATR_Handle==INVALID_HANDLE)Print(" Error in creation of ATR indicator");

//---- set IndBuffer[] as indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- set horizontal shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- define empty values (not shown at chart)
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set indexing as time series
   ArraySetAsSeries(IndBuffer,true);

//--- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"Ultimate Oscillator");

//--- set plot precision
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization finished
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // total bars in the history
                const int prev_calculated,// bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- check calculated bars
   if(BarsCalculated(FATR_Handle)<rates_total
      || BarsCalculated(MATR_Handle)<rates_total
      || BarsCalculated(SATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of double variables
   double FATR[],MATR[],SATR[],value,fast,middle,slow,RawUO;
//---- declaration of integer variables
   int to_copy,limit,bar,maxbar1,maxbar2;

//---- calculation of starting bar index
   if(prev_calculated>rates_total || prev_calculated<=0)// check for the first call
     {
      limit=rates_total-2;                 // starting index for all bars
     }
   else limit=rates_total-prev_calculated; // starting index for new bars
   
   maxbar1=rates_total-2;
   maxbar2=maxbar1-min_rates_total;

//---- set indexing as time series
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(FATR,true);
   ArraySetAsSeries(MATR,true);
   ArraySetAsSeries(SATR,true);
   to_copy=limit+1;
   
//---- copy new data to arrays
   if(CopyBuffer(FATR_Handle,0,0,to_copy,FATR)<=0) return(RESET);
   if(CopyBuffer(MATR_Handle,0,0,to_copy,MATR)<=0) return(RESET);
   if(CopyBuffer(SATR_Handle,0,0,to_copy,SATR)<=0) return(RESET);

//---- calculation of indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      value=close[bar]-MathMin(low[bar],close[bar+1]);
      
      fast=FXMA.XMASeries(maxbar1,prev_calculated,rates_total,0,1,fastperiod,value,bar,true);
      middle=MXMA.XMASeries(maxbar1,prev_calculated,rates_total,0,1,middleperiod,value,bar,true);
      slow=SXMA.XMASeries(maxbar1,prev_calculated,rates_total,0,1,slowperiod,value,bar,true);
      
      if(bar>maxbar2) continue;
      
      RawUO=fastK*fast/FATR[bar]+middleK*middle/MATR[bar]+slowK*slow/SATR[bar];
      IndBuffer[bar]=RawUO/divider*100;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
