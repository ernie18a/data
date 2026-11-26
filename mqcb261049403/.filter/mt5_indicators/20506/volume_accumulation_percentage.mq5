//+------------------------------------------------------------------+
//|                               Volume_Accumulation_Percentage.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volume Accumulation Percentage indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot VACC
#property indicator_label1  "VACC"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferVACC[];
double         BufferColors[];
double         BufferVA[];
double         BufferVol[];
double         BufferVAA[];
double         BufferVolA[];
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
   SetIndexBuffer(0,BufferVACC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferVA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVAA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVolA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Volume Accumulation Percentage");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVACC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferVA,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVAA,true);
   ArraySetAsSeries(BufferVolA,true);
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
   if(rates_total<4 || Point()==0) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVACC,0);
      ArrayInitialize(BufferVA,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVAA,0);
      ArrayInitialize(BufferVolA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVA[i]=(high[i]-low[i]!=0 ? Point()*tick_volume[i]*(2*close[i]-high[i]-low[i])/(high[i]-low[i]) : 0);
      BufferVol[i]=tick_volume[i]*Point();
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVA,BufferVAA);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferVolA);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVACC[i]=(BufferVolA[i]!=0 ? 100.0*BufferVAA[i]/BufferVolA[i] : 0);
      BufferColors[i]=(BufferVACC[i]<BufferVACC[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
