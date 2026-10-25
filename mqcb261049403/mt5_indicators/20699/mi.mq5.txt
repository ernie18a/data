//+------------------------------------------------------------------+
//|                                                           MI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Mass Index (MI)"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot MI
#property indicator_label1  "Mass IDX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriodMA1   =  9;          // First smoothing period
input uint           InpPeriodMA2   =  9;          // Second smoothing period
input uint           InpPeriodSum   =  25;         // Resulting smoothing period
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // Method
//--- indicator buffers
double         BufferMI[];
double         BufferRes[];
double         BufferHL[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferMA3[];
//--- global variables
int            period_ma1;
int            period_ma2;
int            period_sum;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   period_sum=int(InpPeriodSum<2 ? 2 : InpPeriodSum);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRes,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MI("+(string)period_ma1+","+(string)period_ma2+","+(string)period_sum+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMI,true);
   ArraySetAsSeries(BufferHL,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferMA3,true);
   ArraySetAsSeries(BufferRes,true);
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
   //int max=fmax(period_fma,fmax(period_sma,period_sig));
   if(rates_total<4 || Point()==0) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMI,EMPTY_VALUE);
      ArrayInitialize(BufferHL,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferMA3,0);
      ArrayInitialize(BufferRes,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferHL[i]=high[i]-low[i];
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferHL,BufferMA1);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferHL,BufferMA1);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferHL,BufferMA1,weight_sum); break;
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferHL,BufferMA1);                    break;
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma2,BufferMA1,BufferMA2);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma2,BufferMA1,BufferMA2);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma2,BufferMA1,BufferMA2,weight_sum); break;
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma2,BufferMA1,BufferMA2);                    break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRes[i]=BufferMA1[i]/(BufferMA2[i]!=0 ? BufferMA2[i] : 1.0);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sum,BufferRes,BufferMA3);    
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMI[i]=BufferMA3[i]*period_sum-25.0;
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
