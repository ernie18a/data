//+------------------------------------------------------------------+
//|                                          True_Strength_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "True Strength Index oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot TSI
#property indicator_label1  "TSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodSm1   =  7;    // First smoothing period
input uint     InpPeriodSm2   =  14;   // Second smoothing period
input double   InpOverbought  =  25.0; // Overbought
input double   InpOversold    = -25.0; // Oversold
//--- indicator buffers
double         BufferTSI[];
double         BufferUDM[];
double         BufferADM[];
double         BufferUDM1[];
double         BufferUDM2[];
double         BufferADM1[];
double         BufferADM2[];
//--- global variables
double         overbought;
double         oversold;
int            period_sm1;
int            period_sm2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm1=int(InpPeriodSm1<2 ? 2 : InpPeriodSm1);
   period_sm2=int(InpPeriodSm2<2 ? 2 : InpPeriodSm2);
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : InpOverbought>100.0 ? 100.0 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold)<-100.0 ? -100.0 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUDM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferUDM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferUDM2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferADM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferADM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferADM2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"True Strength Index ("+(string)period_sm1+","+(string)period_sm2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTSI,true);
   ArraySetAsSeries(BufferUDM,true);
   ArraySetAsSeries(BufferUDM1,true);
   ArraySetAsSeries(BufferUDM2,true);
   ArraySetAsSeries(BufferADM,true);
   ArraySetAsSeries(BufferADM1,true);
   ArraySetAsSeries(BufferADM2,true);
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
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTSI,EMPTY_VALUE);
      ArrayInitialize(BufferUDM,0);
      ArrayInitialize(BufferUDM1,0);
      ArrayInitialize(BufferUDM2,0);
      ArrayInitialize(BufferADM,0);
      ArrayInitialize(BufferADM1,0);
      ArrayInitialize(BufferADM2,0);
     }

//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUDM[i]=close[i]-close[i+1];
      BufferADM[i]=fabs(BufferUDM[i]);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferUDM,BufferUDM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferADM,BufferADM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_sm1,period_sm2,BufferUDM1,BufferUDM2)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_sm1,period_sm2,BufferADM1,BufferADM2)==0)
      return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTSI[i]=(BufferADM2[i]!=0 ? 100.0*BufferUDM2[i]/BufferADM2[i] : 0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
