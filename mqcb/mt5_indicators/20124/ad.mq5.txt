//+------------------------------------------------------------------+
//|                                                           AD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot AD
#property indicator_label1  "AD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_METHOD
  {
   METHOD_CLASSIC,   // Classical
   METHOD_INC,       // Classical Incremental
   METHOD_TS_INC     // Trade Station Incremental
  };
//--- input parameters
input ENUM_METHOD InpMethod   =  METHOD_CLASSIC;   // AD calculation method
//--- indicator buffers
double         BufferAD[];
double         BufferCurent[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCurent,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"AD");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAD,true);
   ArraySetAsSeries(BufferCurent,true);
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
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit2=limit;
   if(limit>1)
     {
      limit=rates_total-1;
      limit2=limit-1;
      ArrayInitialize(BufferAD,0);
      ArrayInitialize(BufferCurent,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCurent[i]=
        (
         high[i]-low[i]!=0 ?
         InpMethod==METHOD_TS_INC ?
         ((close[i]-open[i])/(high[i]-low[i]))*tick_volume[i] :
         (((close[i]-low[i]) -(high[i]-close[i]))/(high[i]-low[i]))*tick_volume[i] : 0
        );
     }
//--- Расчёт индикатора
   for(int i=limit2; i>=0 && !IsStopped(); i--)
      BufferAD[i]=(InpMethod==METHOD_CLASSIC ? BufferCurent[i] : BufferAD[i+1]+BufferCurent[i]);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
