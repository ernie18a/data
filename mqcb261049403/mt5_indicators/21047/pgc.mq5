//+------------------------------------------------------------------+
//|                                                          PGC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Price Gouging Cycle oscillator"
#property indicator_separate_window
#property indicator_buffers 13
#property indicator_plots   1
//--- plot PGC
#property indicator_label1  "PG Cycle"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod1        =  9;             // First MA period
input uint                 InpPeriod2        =  19;            // Second MA period
input uint                 InpPeriod3        =  6;             // Smoothing period
input uint                 InpPeriodRSI      =  8;             // RSI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  70.0;          // Overbought level
input double               InpOversold       =  30.0;          // Oversold level
//--- indicator buffers
double         BufferPGC[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferAvgMA1[];
double         BufferAvgMA2[];
double         BufferE[];
double         BufferAvgMA3[];
double         BufferAvg2MA3[];
double         BufferZ3[];
double         BufferInc[];
double         BufferDec[];
double         BufferAvgInc[];
double         BufferAvgDec[];
//--- global variables
double         overbought;
double         oversold;
int            period_ma1;
int            period_ma2;
int            period_ma3;
int            period_rsi;
int            weight_sum;
int            handle_ma1;
int            handle_ma2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_ma2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_ma3=int(InpPeriod3<2 ? 2 : InpPeriod3);
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPGC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferE,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvg2MA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferZ3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferInc,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferDec,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferAvgInc,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferAvgDec,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PG Cycle ("+(string)period_ma1+","+(string)period_ma2+","+(string)period_ma3+","+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPGC,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferAvgMA1,true);
   ArraySetAsSeries(BufferAvgMA2,true);
   ArraySetAsSeries(BufferE,true);
   ArraySetAsSeries(BufferAvgMA3,true);
   ArraySetAsSeries(BufferAvg2MA3,true);
   ArraySetAsSeries(BufferZ3,true);
   ArraySetAsSeries(BufferInc,true);
   ArraySetAsSeries(BufferDec,true);
   ArraySetAsSeries(BufferAvgInc,true);
   ArraySetAsSeries(BufferAvgDec,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_ma1,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_ma2,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma2,") object was not created: Error ",GetLastError());
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
      limit=rates_total-2;
      ArrayInitialize(BufferPGC,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferAvgMA1,0);
      ArrayInitialize(BufferAvgMA2,0);
      ArrayInitialize(BufferE,0);
      ArrayInitialize(BufferAvgMA3,0);
      ArrayInitialize(BufferAvg2MA3,0);
      ArrayInitialize(BufferZ3,0);
      ArrayInitialize(BufferInc,0);
      ArrayInitialize(BufferDec,0);
      ArrayInitialize(BufferAvgInc,0);
      ArrayInitialize(BufferAvgDec,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
   
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferMA1,BufferAvgMA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferMA2,BufferAvgMA2);
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double z1=2.0*BufferMA1[i]-BufferAvgMA1[i];
      double z2=2.0*BufferMA2[i]-BufferAvgMA2[i];
      BufferE[i]=z1-z2;
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma3,BufferE,BufferAvgMA3);   
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma3,BufferAvgMA3,BufferAvg2MA3);
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferZ3[i]=2.0*BufferAvgMA3[i]-BufferAvg2MA3[i];
      if(BufferZ3[i]>BufferZ3[i+1])
        {
         BufferInc[i]=BufferZ3[i]-BufferZ3[i+1];
         BufferDec[i]=0;
        }
      else
        {
         if(BufferZ3[i]<BufferZ3[i+1])
           {
            BufferInc[i]=0;
            BufferDec[i]=BufferZ3[i+1]-BufferZ3[i];
           }
         else
           {
            BufferInc[i]=0;
            BufferDec[i]=0;
           }
        }
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_rsi,BufferInc,BufferAvgInc);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_rsi,BufferDec,BufferAvgDec);

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double RS=(BufferAvgDec[i]!=0 ? BufferAvgInc[i]/BufferAvgDec[i] : 0);
      BufferPGC[i]=100.0-100.0/(1.0+RS);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
