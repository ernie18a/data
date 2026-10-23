//+------------------------------------------------------------------+
//|                                                       RSI_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI MA oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot RSIMA
#property indicator_label1  "RSIMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodRSI      =  14;            // RSI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // RSI applied price
input uint                 InpPeriodMA       =  14;            // Smoothing period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Smoothing method
//--- indicator buffers
double         BufferRSIMA[];
double         BufferRSI[];
//--- global variables
int            period_rsi;
int            period_sm;
int            period_max;
int            handle_rsi;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   period_sm=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_max=(int)fmax(period_rsi,period_sm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSIMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI MA ("+(string)period_rsi+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_sm+period_rsi);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSIMA,true);
   ArraySetAsSeries(BufferRSI,true);
//--- create RSI's handles
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
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRSIMA,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm,BufferRSI,BufferRSIMA);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm,BufferRSI,BufferRSIMA);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm,BufferRSI,BufferRSIMA,weight_sum);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm,BufferRSI,BufferRSIMA);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
