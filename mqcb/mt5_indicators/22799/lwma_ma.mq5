//+------------------------------------------------------------------+
//|                                                      LWMA_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "LWMA/SMA ratio oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "LWMA/SMA"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLime,clrDarkOrange,clrGainsboro
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  20;   // Period
//--- indicator buffers
double         BufferDMA[];
double         BufferColors[];
double         BufferSMA[];
double         BufferLWMA[];
//--- global variables
int            period;
int            handle_sma;
int            handle_lwma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferLWMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LWMA/SMA ratio ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDMA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferLWMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create MA's handles
   ResetLastError();
   handle_sma=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_lwma=iMA(NULL,PERIOD_CURRENT,period,0,MODE_LWMA,PRICE_CLOSE);
   if(handle_lwma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDMA,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferLWMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_lwma,0,0,count,BufferLWMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDMA[i]=(BufferSMA[i]!=0 ? (BufferLWMA[i]/BufferSMA[i])-1.0 : 0);
      BufferColors[i]=(BufferDMA[i]>BufferDMA[i+1] ? 0 : BufferDMA[i]<BufferDMA[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
