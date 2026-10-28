//+------------------------------------------------------------------+
//|                                                          RTR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Range To Range indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot RTR
#property indicator_label1  "RTR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodFast  =  2; // Fast ATR Period
input uint     InpPeriodSlow  =  7; // Slow ATR Period
//--- indicator buffers
double         BufferRTR[];
double         BufferFATR[];
double         BufferSATR[];
//--- global variables
int            period_fast;
int            period_slow;
int            handle_fatr;
int            handle_satr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRTR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferSATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Range To Range ("+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRTR,true);
   ArraySetAsSeries(BufferFATR,true);
   ArraySetAsSeries(BufferSATR,true);
//--- create ATR's handles
   ResetLastError();
   handle_fatr=iATR(NULL,PERIOD_CURRENT,period_fast);
   if(handle_fatr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_satr=iATR(NULL,PERIOD_CURRENT,period_slow);
   if(handle_satr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_slow,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferRTR,EMPTY_VALUE);
      ArrayInitialize(BufferFATR,0);
      ArrayInitialize(BufferSATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fatr,0,0,count,BufferFATR);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_satr,0,0,count,BufferSATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRTR[i]=(100.0*BufferFATR[i]/(BufferSATR[i]!=0 ? BufferSATR[i] : 1.0));

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
