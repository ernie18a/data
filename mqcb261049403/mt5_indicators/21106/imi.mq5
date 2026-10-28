//+------------------------------------------------------------------+
//|                                                          IMI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Intraday Momentum Index indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot IMI
#property indicator_label1  "IMI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  14;      // Period
input double   InpOverbought  =  70.0;    // Overbought
input double   InpOversold    =  30.0;    // Oversold
//--- indicator buffers
double         BufferIMI[];
double         BufferUP[];
double         BufferDN[];
double         BufferAvgUP[];
double         BufferAvgDN[];
//--- global variables
double         overbought;
double         oversold;
int            period_ind;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIMI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Intraday Momentum Index ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIMI,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferAvgUP,true);
   ArraySetAsSeries(BufferAvgDN,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferIMI,EMPTY_VALUE);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferAvgUP,0);
      ArrayInitialize(BufferAvgDN,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=close[i]-open[i];
      if(diff>0)
        {
         BufferUP[i]=diff;
         BufferDN[i]=0;
        }
      else
        {
         BufferUP[i]=0;
         BufferDN[i]=-diff;
        }
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferUP,BufferAvgUP);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferDN,BufferAvgDN);
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double U=BufferAvgUP[i];
      double D=BufferAvgDN[i];
      BufferIMI[i]=(U+D!=0 ? 100.0*U/(U+D) : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
