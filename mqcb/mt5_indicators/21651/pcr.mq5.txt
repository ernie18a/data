//+------------------------------------------------------------------+
//|                                                          PCR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Percent Retracement oscillator"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot PCR
#property indicator_label1  "PCR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  10;      // Period
input double   InpOverbought  =  80.0;    // Overbought
input double   InpOversold    =  20.0;    // Oversold
//--- indicator buffers
double         BufferPCR[];
//--- global variables
double         overbought;
double         oversold;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPCR,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Percent Retracement ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPCR,true);
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferPCR,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period,i);
      int bh=Highest(period,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      BufferPCR[i]=(max!=min ? 100.0*(1.0-(max-close[i])/(max-min)) : 0);
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
  }
//+------------------------------------------------------------------+
