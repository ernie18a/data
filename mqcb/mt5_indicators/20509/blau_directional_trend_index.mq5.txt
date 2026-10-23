//+------------------------------------------------------------------+
//|                                 Blau_Directional_Trend_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William Blau Directional Trend Index"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot DTI
#property indicator_label1  "DTIndex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod         =  2;    // Period
input uint     InpPeriodSmooth1  =  20;   // First smoothing period
input uint     InpPeriodSmooth2  =  5;    // Second smoothing period
input uint     InpPeriodSmooth3  =  3;    // Third smoothing period
input double   InpLevelUP        =  25.0; // Upper level
input double   InpLevelDN        = -25.0; // Lower level
//--- indicator buffers
double         BufferDTI[];
double         BufferUDM[];
double         BufferUDM_MA1[];
double         BufferUDM_MA2[];
double         BufferUDM_MA3[];
double         BufferADM[];
double         BufferADM_MA1[];
double         BufferADM_MA2[];
double         BufferADM_MA3[];
//--- global variables
double         level_up;
double         level_dn;
int            period_ind;
int            period_sm1;
int            period_sm2;
int            period_sm3;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm1=int(InpPeriodSmooth1<2 ? 2 : InpPeriodSmooth1);
   period_sm2=int(InpPeriodSmooth2<2 ? 2 : InpPeriodSmooth2);
   period_sm3=int(InpPeriodSmooth3<2 ? 2 : InpPeriodSmooth3);
   level_up=(InpLevelUP<0.1 ? 0.1 : InpLevelUP);
   level_dn=(InpLevelDN>0 ? -InpLevelDN : InpLevelDN>-0.1 ? -0.1 : InpLevelDN);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDTI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUDM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferUDM_MA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferUDM_MA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferUDM_MA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferADM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferADM_MA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferADM_MA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferADM_MA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BDTI("+(string)period_ind+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sm3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level_up);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,level_dn);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDTI,true);
   ArraySetAsSeries(BufferUDM,true);
   ArraySetAsSeries(BufferUDM_MA1,true);
   ArraySetAsSeries(BufferUDM_MA2,true);
   ArraySetAsSeries(BufferUDM_MA3,true);
   ArraySetAsSeries(BufferADM,true);
   ArraySetAsSeries(BufferADM_MA1,true);
   ArraySetAsSeries(BufferADM_MA2,true);
   ArraySetAsSeries(BufferADM_MA3,true);
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
   if(rates_total<period_ind) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-1;
      ArrayInitialize(BufferDTI,EMPTY_VALUE);
      ArrayInitialize(BufferUDM,0);
      ArrayInitialize(BufferUDM_MA1,0);
      ArrayInitialize(BufferUDM_MA2,0);
      ArrayInitialize(BufferUDM_MA3,0);
      ArrayInitialize(BufferADM,0);
      ArrayInitialize(BufferADM_MA1,0);
      ArrayInitialize(BufferADM_MA2,0);
      ArrayInitialize(BufferADM_MA3,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double H=high[i]-high[i+period_ind];
      if(H<0) H=0;
      double L=low[i+period_ind]-low[i];
      if(L<0) L=0;
      BufferUDM[i]=H-L;
      BufferADM[i]=fabs(BufferUDM[i]);
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferUDM,BufferUDM_MA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferADM,BufferADM_MA1);

   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferUDM_MA1,BufferUDM_MA2);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferADM_MA1,BufferADM_MA2);

   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferUDM_MA2,BufferUDM_MA3);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferADM_MA2,BufferADM_MA3);

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferDTI[i]=100.*BufferUDM_MA3[i]/(BufferADM_MA3[i]!=0 ? BufferADM_MA3[i] : DBL_MIN);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
