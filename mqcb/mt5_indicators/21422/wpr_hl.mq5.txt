//+------------------------------------------------------------------+
//|                                                       WPR_HL.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "WPR_HL oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot WPRHL
#property indicator_label1  "WPR HL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  14;   // Period
input double   InpOverbought  =  20;   // Overbought
input double   InpOversold    =  80;   // Oversold
//--- indicator buffers
double         BufferWPRHL[];
double         BufferHL[];
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
   period=int(InpPeriod<2 ? 2 : InpPeriod);
   double ob=-fabs(InpOverbought);
   double os=-fabs(InpOversold);
   overbought=(ob>0 ? 0 : ob<-99.0 ? -99.0 : ob);
   oversold=(os<-100.0 ? -100.0 : os>=overbought ? overbought-1.0 : os);
   if(overbought<=oversold) overbought=oversold+1.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWPRHL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"High/Low WPR ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWPRHL,true);
   ArraySetAsSeries(BufferHL,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4))
      return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferWPRHL,EMPTY_VALUE);
      ArrayInitialize(BufferHL,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferHL[i]=high[i]-low[i];

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferHL,i,period);
      int bh=ArrayMaximum(BufferHL,i,period);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferHL[bl];
      double max=BufferHL[bh];
      BufferWPRHL[i]=(max!=min ? -100.0*(max-BufferHL[i])/(max-min) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
