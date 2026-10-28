//+------------------------------------------------------------------+
//|                                                     FX_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "FX Trend oscillator"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot FXT
#property indicator_label1  "FX Trend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodFast     =  7;    // Small range of bars
input uint     InpPeriodMiddle   =  14;   // Middle range of bars
input uint     InpPeriodSlow     =  28;   // Big range of bars
input double   InpLevel          =  50.0; // Threshold level
//--- indicator buffers
double         BufferFXT[];
//--- global variables
double         level;
double         k;
int            period_fast;
int            period_middle;
int            period_slow;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_middle=int(InpPeriodMiddle<2 ? 2 : InpPeriodMiddle);
   period_slow=int(InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   period_max=fmax(period_fast,fmax(period_middle,period_slow));
   k=100.0/(1.0/period_fast+1.0/period_middle+1.0/period_slow);
   level=(InpLevel<0 ? 0 : InpLevel>100 ? 100 : InpLevel);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFXT,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"FX Trend ("+(string)period_fast+","+(string)period_middle+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFXT,true);
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferFXT,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int blf=Lowest(period_fast,i);
      int bhf=Highest(period_fast,i);
      int blm=Lowest(period_middle,i);
      int bhm=Highest(period_middle,i);
      int bls=Lowest(period_slow,i);
      int bhs=Highest(period_slow,i);
      if(blf==WRONG_VALUE || bhf==WRONG_VALUE || blm==WRONG_VALUE || bhm==WRONG_VALUE || bls==WRONG_VALUE || bhs==WRONG_VALUE)
         continue;
      double minf=low[blf];
      double maxf=high[bhf];
      double minm=low[blm];
      double maxm=high[bhm];
      double mins=low[bls];
      double maxs=high[bhs];
      //---
      double fdiff=maxf-minf;
      double mdiff=maxm-minm;
      double sdiff=maxs-mins;
      //---
      double v=k*((close[i]-minf)/(fdiff*period_fast)+(close[i]-minm)/(mdiff*period_middle)+(close[i]-mins)/(sdiff*period_slow));
      BufferFXT[i]=(v!=0 ? v : close[i]);
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
