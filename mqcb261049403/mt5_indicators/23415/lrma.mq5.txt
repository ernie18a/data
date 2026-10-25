//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Linear Regression Moving Average"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot LWMA
#property indicator_label1  "LRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  34;   // Period
//--- indicator buffers
double         BufferLRMA[];
double         BufferLWMA[];
double         BufferSMA[];
//--- global variables
int            period_lrma;
int            handle_lwma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_lrma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLRMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLWMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LRMA("+(string)period_lrma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLRMA,true);
   ArraySetAsSeries(BufferLWMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create handles
   ResetLastError();
   handle_lwma=iMA(NULL,PERIOD_CURRENT,period_lrma,0,MODE_LWMA,PRICE_CLOSE);
   if(handle_lwma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_lrma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_lrma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_lrma,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_lrma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferLRMA,0);
      ArrayInitialize(BufferLWMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_lwma,0,0,count,BufferLWMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLRMA[i]=3.0*BufferLWMA[i]-2.0*BufferSMA[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
