//+------------------------------------------------------------------+
//|                                                 Smoothed_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed RSI indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot RSI
#property indicator_label1  "Smoothed RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOliveDrab
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodSRC      =  10;            // Source period
input ENUM_MA_METHOD       InpMethodSRC      =  MODE_SMA;      // Source method
input ENUM_APPLIED_PRICE   InpAppliedPriceSRC=  PRICE_CLOSE;   // Source applied price
input uint                 InpPeriodRSI      =  10;            // Smoothed RSI period
input ENUM_MA_METHOD       InpMethodRSI      =  MODE_SMA;      // Smoothed RSI method
input double               InpLevTop         =  70.0;          // Top level
input double               InpLevBottom      =  30.0;          // Bottom level
//--- indicator buffers
double         BufferRSI[];
double         BufferMA[];
double         BufferPositive[];
double         BufferNegative[];
double         BufferAvgPositive[];
double         BufferAvgNegative[];
//--- global variables
double         overbought;
double         oversold;
int            period_src;
int            period_rsi;
int            handle_ma;
int            weight_sumP;
int            weight_sumN;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_src=int(InpPeriodSRC<2 ? 2 : InpPeriodSRC);
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   overbought=(InpLevTop>100 ? 100 : InpLevTop<0.1 ? 0.1 : InpLevTop);
   oversold=(InpLevBottom<0 ? 0 : InpLevBottom>=overbought ? overbought-0.1 : InpLevBottom);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPositive,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNegative,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgPositive,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgNegative,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed RSI ("+(string)period_src+","+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Top");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Bottom");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPositive,true);
   ArraySetAsSeries(BufferNegative,true);
   ArraySetAsSeries(BufferAvgPositive,true);
   ArraySetAsSeries(BufferAvgNegative,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_src,0,InpMethodSRC,InpAppliedPriceSRC);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_src,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<fmax(period_rsi,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferPositive,0);
      ArrayInitialize(BufferNegative,0);
      ArrayInitialize(BufferAvgPositive,0);
      ArrayInitialize(BufferAvgNegative,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=BufferMA[i]-close[i];
      if(diff>0)
        {
         BufferPositive[i]=diff;
         BufferNegative[i]=0;
        }
      else
        {
         BufferNegative[i]=-diff;
         BufferPositive[i]=0;
        }
     }
   switch(InpMethodRSI)
     {
      case MODE_EMA  :
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferPositive,BufferAvgPositive)==0) return 0;
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferNegative,BufferAvgNegative)==0) return 0;
        break;
      case MODE_SMMA :
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferPositive,BufferAvgPositive)==0) return 0;
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferNegative,BufferAvgNegative)==0) return 0;
        break;
      case MODE_LWMA :
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferPositive,BufferAvgPositive,weight_sumP)==0) return 0;
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferNegative,BufferAvgNegative,weight_sumN)==0) return 0;
        break;
      //---MODE_SMA
      default        :
        if(SimpleMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferPositive,BufferAvgPositive)==0) return 0;
        if(SimpleMAOnBuffer(rates_total,prev_calculated,period_src,period_rsi,BufferNegative,BufferAvgNegative)==0) return 0;
        break;
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRSI[i]=(BufferAvgNegative[i]!=0 ? 100.0-(100.0/(1.0+BufferAvgPositive[i]/BufferAvgNegative[i])) : 0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
