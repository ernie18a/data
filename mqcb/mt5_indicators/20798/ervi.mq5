//+------------------------------------------------------------------+
//|                                                         ERVI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "John F.Ehlers RVI oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot RVI
#property indicator_label1  "RVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod=10;   // Period
//--- indicator buffers
double         BufferRVI[];
double         BufferSignal[];
double         BufferValue1[];
double         BufferValue2[];
double         BufferSMAV1[];
double         BufferSMAV2[];
//--- global variables
int            period_sm;
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
   SetIndexBuffer(0,BufferRVI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferValue1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferValue2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSMAV1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMAV2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ERVI("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRVI,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferValue1,true);
   ArraySetAsSeries(BufferValue2,true);
   ArraySetAsSeries(BufferSMAV1,true);
   ArraySetAsSeries(BufferSMAV2,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-4;
      ArrayInitialize(BufferRVI,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferValue1,0);
      ArrayInitialize(BufferValue2,0);
      ArrayInitialize(BufferSMAV1,0);
      ArrayInitialize(BufferSMAV2,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferValue1[i]=((close[i]-open[i])+2.0*(close[i+1]-open[i+1])+2.0*(close[i+2]-open[i+2])+(close[i+3]-open[i+3]))/6.0;
      BufferValue2[i]=((high[i]-low[i])+2.0*(high[i+1]-low[i+1])+2.0*(high[i+2]-low[i+2])+(high[i+3]-low[i+3]))/6.0;
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferValue1,BufferSMAV1);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferValue2,BufferSMAV2);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double num=BufferSMAV1[i];
      double denom=BufferSMAV2[i];
      BufferRVI[i]=(denom!=0 ? num/denom : 0);
      BufferSignal[i]=(BufferRVI[i]+2.0*BufferRVI[i+1]+2.0*BufferRVI[i+2]+BufferRVI[i+3])/6.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
