//+------------------------------------------------------------------+
//|                                                    MinMax_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMA[];
double         BufferPrice[];
//--- global variables
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPrice,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Minimum-maximum Moving Average");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create MA and ATR handles
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int min_b=ArrayMinimum(BufferPrice,i,period);
      int max_b=ArrayMaximum(BufferPrice,i,period);
      if(min_b==WRONG_VALUE || max_b==WRONG_VALUE) continue;
      double min=BufferPrice[min_b];
      double max=BufferPrice[max_b];
      BufferMA[i]=(min+max)/2.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
