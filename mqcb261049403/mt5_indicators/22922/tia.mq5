//+------------------------------------------------------------------+
//|                                                          TIA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Interruption Average oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "TIA Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "TIA Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Diff
#property indicator_label3  "TIA Difference"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriod   =  14;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferDiff[];
double         BufferTmpUP[];
double         BufferTmpDN[];
//--- global variables
int            period_sm;
int            weight_sum1;
int            weight_sum2;
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
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDiff,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTmpUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTmpDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TIA Oscillator ("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferTmpUP,true);
   ArraySetAsSeries(BufferTmpDN,true);
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sm-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferDiff,EMPTY_VALUE);
      ArrayInitialize(BufferTmpUP,0);
      ArrayInitialize(BufferTmpDN,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTmpUP[i]=BufferTmpDN[i]=0;
      if(close[i]>close[i+1])
        {
         BufferTmpUP[i]=BufferTmpUP[i+1]+1;
         BufferTmpDN[i]=0;
        }
      if(close[i]<close[i+1])
        {
         BufferTmpDN[i]=BufferTmpDN[i+1]+1;
         BufferTmpUP[i]=0;
        }
     }

//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpUP,BufferUP)==0) return 0;
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpDN,BufferDN)==0) return 0;
        break;
      case MODE_SMMA :
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpUP,BufferUP)==0) return 0;
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpDN,BufferDN)==0) return 0;
        break;
      case MODE_LWMA :
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpUP,BufferUP,weight_sum1)==0) return 0;
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpDN,BufferDN,weight_sum2)==0) return 0;
        break;
      //---MODE_SMA
      default        :
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpUP,BufferUP)==0) return 0;
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTmpDN,BufferDN)==0) return 0;
        break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDiff[i]=BufferUP[i]-BufferDN[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
