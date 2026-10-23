//+------------------------------------------------------------------+
//|                                                           RP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Range Position oscillator"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot RP
#property indicator_label1  "Range Position"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRosyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  14;   // Range period
input double   InpLevel1   =  38.2; // First level
input double   InpLevel2   =  50.0; // Second level
input double   InpLevel3   =  61.8; // Third level
//--- indicator buffers
double         BufferRP[];
//--- global variables
int            period;
double         level1;
double         level2;
double         level3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   level1=(InpLevel1<1 ? 1 : InpLevel1>97 ? 97 : InpLevel1);
   level2=(InpLevel2<=level1 ? level1+1 : InpLevel2>98 ? 98 : InpLevel2);
   level3=(InpLevel3<=level2 ? level2+1 : InpLevel3>99 ? 99 : InpLevel3);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRP,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Range Position ("+(string)period+" bars)");
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,level3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,level2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,level1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRP,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRP,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period,i+1);
      int bh=Highest(period,i+1);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      if(max!=min)
         BufferRP[i]=100.0*(close[i]-min)/(max-min);
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
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
