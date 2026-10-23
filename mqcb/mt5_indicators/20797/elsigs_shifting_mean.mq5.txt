//+------------------------------------------------------------------+
//|                                         Elsigs_Shifting_Mean.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Elsig's Shifting Mean"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot ESM
#property indicator_label1  "ESM"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod=5; // Period
//--- indicator buffers
double         BufferESM[];
//--- global variables
int   period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferESM,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ESM("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferESM,true);
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
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferESM,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int f=int(rates_total-floor((rates_total-i)/period)*period);
      int bl=Lowest(period,f);
      int bh=Highest(period,f);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      BufferESM[i]=(min+max)/2.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Low           |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
