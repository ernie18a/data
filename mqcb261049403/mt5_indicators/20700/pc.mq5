//+------------------------------------------------------------------+
//|                                                           PC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Price Cycle oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot PC
#property indicator_label1  "Price Cycle"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod      =  14;         // Period
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;   // Method
input double         InpOverbought  =  70.0;       // Overbought
input double         InpOversold    =  30.0;       // Oversold
//--- indicator buffers
double         BufferPC[];
double         BufferRAW[];
double         BufferATR[];
double         BufferMAA[];
//--- global variables
double         overbought;
double         oversold;
int            period_sm;
int            handle_atr;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold<0 ? 0 : InpOversold> 99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Price Cycle("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPC,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferMAA,true);
//--- create MA's handle
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_sm);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_sm,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period_sm) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferPC,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferMAA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW[i]=close[i]-low[i];
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRAW,BufferMAA);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRAW,BufferMAA);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRAW,BufferMAA,weight_sum); break;
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRAW,BufferMAA);                    break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferPC[i]=100.0*BufferMAA[i]/(BufferATR[i]!=0 ? BufferATR[i] : 1.0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
