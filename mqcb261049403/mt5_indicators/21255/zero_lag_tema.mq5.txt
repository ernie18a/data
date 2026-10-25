//+------------------------------------------------------------------+
//|                                                Zero_Lag_TEMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Zero Lag Triple Exponential Moving Average"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot TEMA
#property indicator_label1  "ZL TEMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  50;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTEMA[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferEMA3[];
double         BufferTEMA1[];
double         BufferEMA4[];
double         BufferEMA5[];
double         BufferEMA6[];
//--- global variables
int            period_ind;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTEMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferEMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferEMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferEMA4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferEMA5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferEMA6,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero Lag TEMA ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTEMA,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferEMA3,true);
   ArraySetAsSeries(BufferTEMA1,true);
   ArraySetAsSeries(BufferEMA4,true);
   ArraySetAsSeries(BufferEMA5,true);
   ArraySetAsSeries(BufferEMA6,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ind,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ind,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferTEMA,EMPTY_VALUE);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferEMA3,0);
      ArrayInitialize(BufferTEMA1,0);
      ArrayInitialize(BufferEMA4,0);
      ArrayInitialize(BufferEMA5,0);
      ArrayInitialize(BufferEMA6,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferEMA1);
   if(copied!=count) return 0;

   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMA1,BufferEMA2)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMA2,BufferEMA3)==0)
      return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTEMA1[i]=3.0*(BufferEMA1[i]-BufferEMA2[i])+BufferEMA3[i];
      
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferTEMA1,BufferEMA4)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMA4,BufferEMA5)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMA5,BufferEMA6)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double TEMA2=3.0*(BufferEMA4[i]-BufferEMA5[i])+BufferEMA6[i];
      double diff=BufferTEMA1[i]-TEMA2;
      BufferTEMA[i]=BufferTEMA1[i]+diff;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
