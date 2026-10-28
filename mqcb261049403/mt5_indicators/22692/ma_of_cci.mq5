//+------------------------------------------------------------------+
//|                                                    MA_Of_CCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MA of CCI oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot CCI
#property indicator_label1  "CCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodCCI      =  14;            // CCI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // CCI applied price
input uint                 InpPeriodMA       =  20;            // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
//--- indicator buffers
double         BufferCCI[];
double         BufferMA[];
//--- global variables
int            period_cci;
int            period_ma;
int            period_max;
int            handle_cci;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_max=fmax(period_cci,period_ma);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MA of CCI ("+(string)period_cci+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferMA,true);
//--- create cci handle
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,InpAppliedPrice);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCCI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }

//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   ResetLastError();
   int copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,period_cci,period_ma,BufferCCI,BufferMA);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,period_cci,period_ma,BufferCCI,BufferMA);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_cci,period_ma,BufferCCI,BufferMA,weight_sum);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,period_cci,period_ma,BufferCCI,BufferMA);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
