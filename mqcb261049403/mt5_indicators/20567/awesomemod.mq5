//+------------------------------------------------------------------+
//|                                                   AwesomeMod.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Awesome Modified oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
//--- plot AOSlow
#property indicator_label1  "Slow AO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot AOFast
#property indicator_label2  "Fast AO"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGreen,clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint                 InpPeriodFastEMA     =  18;            // Fast EMA period
input uint                 InpPeriodMediumEMA   =  40;            // Medium EMA period
input uint                 InpPeriodSlowEMA     =  200;           // Slow EMA period
input uint                 InpPeriodFastAO      =  12;            // AO. Fast MA period
input uint                 InpPeriodSlowAO      =  18;            // AO. Slow MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferSAO[];
double         BufferSAOColors[];
double         BufferFAO[];
double         BufferFAOColors[];
double         BufferFEMA[];
double         BufferMEMA[];
double         BufferSEMA[];
double         BufferSAOTMP[];
double         BufferFAOTMP[];
//--- global variables
int            period_fema;
int            period_mema;
int            period_sema;
int            period_fao;
int            period_sao;
int            handle_fma;
int            handle_mma;
int            handle_sma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fema=int(InpPeriodFastEMA<1 ? 1 : InpPeriodFastEMA);
   period_mema=int(InpPeriodMediumEMA<1 ? 1 : InpPeriodMediumEMA);
   period_sema=int(InpPeriodSlowEMA<1 ? 1 : InpPeriodSlowEMA);
   period_fao=int(InpPeriodFastAO<2 ? 2 : InpPeriodFastAO);
   period_sao=int(InpPeriodSlowAO<2 ? 2 : InpPeriodSlowAO);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSAO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSAOColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferFAO,INDICATOR_DATA);
   SetIndexBuffer(3,BufferFAOColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferFEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSAOTMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferFAOTMP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"AOModOSC("+(string)period_fema+","+(string)period_mema+","+(string)period_sema+","+(string)period_fao+","+(string)period_sao+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSAO,true);
   ArraySetAsSeries(BufferSAOColors,true);
   ArraySetAsSeries(BufferFAO,true);
   ArraySetAsSeries(BufferFAOColors,true);
   ArraySetAsSeries(BufferFEMA,true);
   ArraySetAsSeries(BufferMEMA,true);
   ArraySetAsSeries(BufferSEMA,true);
   ArraySetAsSeries(BufferSAOTMP,true);
   ArraySetAsSeries(BufferFAOTMP,true);
//--- create MA's handle
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fema,0,MODE_EMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The Fast iMA(",(string)period_fema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mma=iMA(NULL,PERIOD_CURRENT,period_mema,0,MODE_EMA,InpAppliedPrice);
   if(handle_mma==INVALID_HANDLE)
     {
      Print("The Medium iMA(",(string)period_mema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sema,0,MODE_EMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The Slow iMA(",(string)period_sema,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSAO,EMPTY_VALUE);
      ArrayInitialize(BufferFAO,EMPTY_VALUE);
      ArrayInitialize(BufferFEMA,0);
      ArrayInitialize(BufferMEMA,0);
      ArrayInitialize(BufferSEMA,0);
      ArrayInitialize(BufferSAOTMP,0);
      ArrayInitialize(BufferFAOTMP,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_fma,0,0,count,BufferFEMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mma,0,0,count,BufferMEMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSEMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferFAOTMP[i]=(BufferMEMA[i]!=0 ? 100.0*(BufferFEMA[i]/BufferMEMA[i]-1.0) : 0);
      BufferSAOTMP[i]=(BufferSEMA[i]!=0 ? 100.0*(BufferMEMA[i]/BufferSEMA[i]-1.0) : 0);
     }
//--- Расчёт индикатора
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sao,BufferSAOTMP,BufferSAO);   
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_fao,BufferFAOTMP,BufferFAO);   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSAOColors[i]=(BufferSAO[i+1]<BufferSAO[i] ? 0 : 1);
      BufferFAOColors[i]=(BufferFAO[i+1]<BufferFAO[i] ? 0 : 1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
