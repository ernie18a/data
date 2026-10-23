//+------------------------------------------------------------------+
//|                                                    Stoch_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Adaptable Stochastic RSI indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot K
#property indicator_label1  "Slow %K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "Slow %D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodRSI      =  14;            // RSI Period
input uint                 InpPeriodStoK     =  14;            // Stoch Period
input uint                 InpSlowingK       =  3;             // Stoch Slowing K
input uint                 InpSlowingD       =  5;             // Stoch Slowing D
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferRSI[];
double         BufferSKI[];
//--- global variables
int            period_rsi;
int            period_k;
int            period_sk;
int            period_sd;
int            handle_rsi;
int            weight_sum;
double         overbought;
double         oversold;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_k=int(InpPeriodStoK<1 ? 1 : InpPeriodStoK);
   period_sk=int(InpSlowingK<2 ? 2 : InpSlowingK);
   period_sd=int(InpSlowingD<2 ? 2 : InpSlowingD);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSKI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptable Stochastic RSI ("+(string)period_rsi+","+(string)period_k+","+(string)period_sk+","+(string)period_sd+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferSKI,true);
//--- create MA's handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferK,EMPTY_VALUE);
      ArrayInitialize(BufferD,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferSKI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferRSI,i,period_k);
      int bh=ArrayMaximum(BufferRSI,i,period_k);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferRSI[bl];
      double max=BufferRSI[bh];
      BufferSKI[i]=(min==max ? 100.0 : 100.0*(BufferRSI[i]-min)/(max-min));
     }

//--- Расчёт индикатора
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_k,period_sk,BufferSKI,BufferK)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_sk,period_sd,BufferK,BufferD)==0)
      return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
