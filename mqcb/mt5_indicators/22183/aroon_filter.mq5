//+------------------------------------------------------------------+
//|                                                 Aroon_Filter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Aroon Filter oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot AH
#property indicator_label1  "Aroon Filter"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  10;   // Period
input double   InpFilter   =  25.0; // Filter
//--- indicator buffers
double         BufferAF[];
double         BufferColors[];
//--- global variables
double         filter;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   filter=fabs(InpFilter);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Aroon Filter ("+(string)period+","+DoubleToString(filter,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAF,true);
   ArraySetAsSeries(BufferColors,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferAF,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period,i);
      int bh=Highest(period,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double up=100.0*(period-bh+i)/period;
      double dn=100.0*(period-bl+i)/period;
      BufferAF[i]=up-dn;
     }

//--- Цвет
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferColors[i]=(BufferAF[i]>=filter ? 1 : BufferAF[i]<=-filter ? 2 : 0);
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
