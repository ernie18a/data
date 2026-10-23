//+------------------------------------------------------------------+
//|                                                          PVT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Price volume trend oscillator"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot PVT
#property indicator_label1  "PVT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         BufferPVT[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPVT,INDICATOR_DATA);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Price volume trend");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPVT,true);
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
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferPVT,0);
     }
//--- Расчёт индикатора
   int index=WRONG_VALUE;
   for(int i=limit; i>=0; i--)
      BufferPVT[i]=(close[i]-close[i+1])*tick_volume[i]/close[i+1]+BufferPVT[i+1];

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
