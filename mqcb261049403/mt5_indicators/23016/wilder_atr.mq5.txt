//+------------------------------------------------------------------+
//|                                                   Wilder_ATR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wilder ATR indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot WATR
#property indicator_label1  "Wilder ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  14;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferWATR[];
double         BufferTR[];
//--- global variables
int            period_sm;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWATR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wilder ATR ("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWATR,true);
   ArraySetAsSeries(BufferTR,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferWATR,EMPTY_VALUE);
      ArrayInitialize(BufferTR,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double hl=high[i]-low[i];
      double hc=fabs(high[i]-close[i+1]);
      double lc=fabs(low[i]-close[i+1]);
      BufferTR[i]=fmax(hl,fmax(hc,lc));
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTR,BufferWATR);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTR,BufferWATR);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTR,BufferWATR,weight_sum);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTR,BufferWATR);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
