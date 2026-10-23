//+------------------------------------------------------------------+
//|                                                     TriMAgen.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Triangular Moving Average generalized by J.Ehlers"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot TriMAgen
#property indicator_label1  "TriMAgen"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOliveDrab
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTriMAgen[];
double         BufferMA[];
//--- global variables
int            period;
int            handle_ma;
int            len1;
int            len2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   len1=(int)floor((period+1.0)/2);
   len2=(int)ceil((period+1.0)/2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTriMAgen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TriMAgen("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTriMAgen,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,len1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)len1,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(len2,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-len2-1;
      ArrayInitialize(BufferTriMAgen,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      for(int j=0; j<len2; j++)
         sum+=BufferMA[i+j];
      BufferTriMAgen[i]=sum/len2;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
