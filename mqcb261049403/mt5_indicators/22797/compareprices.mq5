//+------------------------------------------------------------------+
//|                                                ComparePrices.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Compare Prices indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot MainPrice
#property indicator_label1  "Main Price"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LogPrice
#property indicator_label2  "Log10 Price"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpShift =  1;    // Prices shift
//--- indicator buffers
double         BufferMainPrice[];
double         BufferLogPrice[];
//--- global variables
int            shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   shift=int(InpShift<1 ? 1 : InpShift);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMainPrice,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLogPrice,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ComparePrices ("+(string)shift+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMainPrice,true);
   ArraySetAsSeries(BufferLogPrice,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(shift,2)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shift-1;
      ArrayInitialize(BufferMainPrice,EMPTY_VALUE);
      ArrayInitialize(BufferLogPrice,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMainPrice[i]=close[i];
      BufferLogPrice[i]=(close[i]!=0 ? close[i]/(1.0+log10(close[i+shift]/close[i])) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
