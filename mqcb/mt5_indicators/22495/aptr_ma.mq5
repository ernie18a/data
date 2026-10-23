//+------------------------------------------------------------------+
//|                                                      APTR_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average Percentage True Range indicator with MA adjustments"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot APTRm
#property indicator_label1  "APTR MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  14;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // MA method
//--- indicator buffers
double         BufferAPTR[];
double         BufferPTR[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAPTR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string name="APTR "+MethodToString(InpMethod)+" ("+(string)period_ma+")";
   IndicatorSetString(INDICATOR_SHORTNAME,name);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,name);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAPTR,true);
   ArraySetAsSeries(BufferPTR,true);
   ArraySetAsSeries(BufferMA,true);
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferAPTR,EMPTY_VALUE);
      ArrayInitialize(BufferPTR,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double s1=(high[i]+low[i]!=0     ? 2.0*(high[i]-low[i])/(high[i]+low[i])           : 0);
      double s2=(high[i]+close[i+1]!=0 ? 2.0*(high[i]-close[i+1])/(high[i]+close[i+1])   : 0);
      double s3=(low[i]-close[i+1]!=0  ? 2.0*(low[i]-close[i+1])/(3.0*low[i]-close[i+1]) : 0);
      BufferPTR[i]=fmax(s1,fmax(s2,s3));
     }
     
//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferPTR,BufferMA)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferPTR,BufferMA)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferPTR,BufferMA,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferPTR,BufferMA)==0) return 0;                    break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferAPTR[i]=100.0*BufferMA[i];

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает метод расчёта как текст                               |
//+------------------------------------------------------------------+
string MethodToString(const ENUM_MA_METHOD method)
  {
   return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+
