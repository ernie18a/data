//+------------------------------------------------------------------+
//|                                                  BuffAverage.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Buff Dormeier's Moving Average"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot BMA
#property indicator_label1  "BMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  20;   // Period
//--- indicator buffers
double         BufferBMA[];
double         BufferVC[];
double         BufferVol[];
double         BufferAvgVC[];
double         BufferAvgVol[];
//--- global variables
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
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgVC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Buff Dormeier MA ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBMA,true);
   ArraySetAsSeries(BufferVC,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferAvgVC,true);
   ArraySetAsSeries(BufferAvgVol,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferBMA,EMPTY_VALUE);
      ArrayInitialize(BufferVC,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferAvgVC,0);
      ArrayInitialize(BufferAvgVol,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVol[i]=(double)tick_volume[i];
      BufferVC[i]=tick_volume[i]*close[i];
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVC,BufferAvgVC)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAvgVol)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AvgVC=BufferAvgVC[i];
      double AvgVol=BufferAvgVol[i];
      BufferBMA[i]=(AvgVol!=0 ? AvgVC/AvgVol : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
