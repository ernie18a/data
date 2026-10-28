//+------------------------------------------------------------------+
//|                                                     Blau_Mtm.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William Blau Momentum oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot BMom
#property indicator_label1  "BMomentum"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  2;             // Period
input uint                 InpPeriodSmooth1  =  20;            // First smoothing period
input uint                 InpPeriodSmooth2  =  5;             // Second smoothing period
input uint                 InpPeriodSmooth3  =  3;             // Third smoothing period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferBMom[];
double         BufferMA[];
double         BufferMom[];
double         BufferEMA1[];
double         BufferEMA2[];
//--- global variables
int            period_ind;
int            period_sm1;
int            period_sm2;
int            period_sm3;
int            handle_ma;
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
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBMom,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMom,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferEMA2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BMomentum("+(string)period_ind+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sm3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBMom,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMom,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<period_ind) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-1;
      ArrayInitialize(BufferBMom,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMom,0);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMom[i]=BufferMA[i]-BufferMA[i+period_ind-1];
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferMom,BufferEMA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferEMA1,BufferEMA2);
//--- Расчёт индикатора
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferEMA2,BufferBMom);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
