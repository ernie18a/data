//+------------------------------------------------------------------+
//|                                                         RIND.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "\"RIND\": Range Indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot RIND
#property indicator_label1  "RIND"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSlateGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod      =  3;          // Period
input uint           InpSmoothing   =  10;         // Smoothing
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // Method
input double         InpLevel0      =  20;         // Level 1
input double         InpLevel1      =  30;         // Level 2
input double         InpLevel2      =  40;         // Level 3
input double         InpLevel3      =  50;         // Level 4
//--- indicator buffers
double         BufferRIND[];
double         BufferRange[];
double         BufferValue[];
//--- global variables
int            period_ind;
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
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpSmoothing<2 ? 2 : InpSmoothing);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRIND,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRange,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferValue,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Range Indicator ("+(string)period_ind+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,InpLevel0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,InpLevel1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,InpLevel2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,InpLevel3);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRIND,true);
   ArraySetAsSeries(BufferRange,true);
   ArraySetAsSeries(BufferValue,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferRIND,EMPTY_VALUE);
      ArrayInitialize(BufferRange,0);
      ArrayInitialize(BufferValue,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double trueRange=fmax(high[i],close[i+1])-fmin(low[i],close[i+1]);
      BufferValue[i]=(close[i]>close[i+1] ? trueRange/(close[i]-close[i+1]) : trueRange);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferValue,i,period_ind);
      int bh=ArrayMaximum(BufferValue,i,period_ind);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferValue[bl];
      double max=BufferValue[bh];
      BufferRange[i]=(max-min>0 ? 100.0*(BufferValue[i]-min)/(max-min) : 100.0*(BufferValue[i]-min));
     }

//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRange,BufferRIND);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRange,BufferRIND);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRange,BufferRIND,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRange,BufferRIND);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
