//+------------------------------------------------------------------+
//|                                                          PFE.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Polarized Fractal Efficiency oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot PFE
#property indicator_label1  "PFE"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodFastROC  =  1;    // Fast ROC period
input uint     InpPeriodSlowROC  =  9;    // Slow ROC period
input uint     InpPeriodMA       =  5;    // MA period
input int      InpPDS            =  10;   // PDS
//--- indicator buffers
double         BufferPFE[];
double         BufferRAW[];
//--- global variables
int            period_froc;
int            period_sroc;
int            period_ma;
int            period_max;
int            pds;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_froc=int(InpPeriodFastROC<1 ? 1 : InpPeriodFastROC);
   period_sroc=int(InpPeriodSlowROC<1 ? 1 : InpPeriodSlowROC);
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_max=fmax(period_froc,period_sroc);
   pds=InpPDS;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPFE,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Polarized Fractal Efficiency ("+(string)period_froc+","+(string)period_sroc+","+(string)period_ma+","+(string)pds+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPFE,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferPFE,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ROCSlow=(close[i+period_sroc]!=0 ? 100.0*(close[i]/close[i+period_sroc]-1) : 0);
      double ROCFast=(close[i+period_froc]!=0 ? 100.0*(close[i]/close[i+period_froc]-1) : 0);
      double x=sqrt(ROCSlow*ROCSlow+100.0);
      double y=sqrt(ROCFast*ROCFast+1.0)+pds;
      double z=x/(y!=0 ? y : 1);
      BufferRAW[i]=(close[i]>close[i+period_sroc] ? 100.0*z : -100.0*z);
     }
//--- Расчёт индикатора
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferRAW,BufferPFE)==0)
      return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
