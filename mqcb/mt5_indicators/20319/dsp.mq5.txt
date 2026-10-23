//+------------------------------------------------------------------+
//|                                                          DSP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Detrended Synthetic Price"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot DSP
#property indicator_label1  "DSP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Half-period MA
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDSP[];
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
int            period1;
int            period2;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod<1 ? 1 : InpPeriod);
   period2=period1*2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDSP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DSP("+(string)period1+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDSP,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- create MA fast handle
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period1,0,InpMethod,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create MA slow handle
   ResetLastError();
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period2,0,InpMethod,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period2,") object was not created: Error ",GetLastError());
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
   if(rates_total<1) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDSP,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferDSP[i]=BufferMA1[i]-BufferMA2[i];
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
