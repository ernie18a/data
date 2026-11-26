//+------------------------------------------------------------------+
//|                                                 PVI_Smoothed.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed Positive Volume Index"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot PVI
#property indicator_label1  "SPVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Sig
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodSmooth   =  5;    // Smoothing period
input uint     InpPeriodSignal   =  15;   // Signal line period
//--- indicator buffers
double         BufferPVI[];
double         BufferSig[];
double         BufferRAW[];
//--- global variables
int            period_pvi;
int            period_sig;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_pvi=int(InpPeriodSmooth<1 ? 1 : InpPeriodSmooth);
   period_sig=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPVI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSig,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SPVI("+(string)period_pvi+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPVI,true);
   ArraySetAsSeries(BufferSig,true);
   ArraySetAsSeries(BufferRAW,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int max=fmax(period_sig,period_pvi);
   if(limit>1)
     {
      limit=rates_total-max-2;
      ArrayInitialize(BufferPVI,0);
      ArrayInitialize(BufferSig,0);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-max-2)
         BufferRAW[i]=1;
      else
        {
         if(tick_volume[i]>tick_volume[i+1])
            BufferRAW[i]=BufferRAW[i+1]*(1+((close[i]-close[i+1])/close[i+1]));
         else
            BufferRAW[i]=BufferRAW[i+1];
        }
     }
//--- Расчёт индикатора
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_pvi,BufferRAW,BufferPVI);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferPVI,BufferSig);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
