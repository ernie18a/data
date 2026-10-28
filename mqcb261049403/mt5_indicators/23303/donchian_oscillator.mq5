//+------------------------------------------------------------------+
//|                                          Donchian_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Donchian Oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot DOsc
#property indicator_label1  "Donchian Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  8
//--- input parameters
input uint     InpPeriod=20;   // Period
//--- indicator buffers
double         BufferDOsc[];
double         BufferColors[];
//--- global variables
int               period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDOsc,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Donchian Oscillator ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDOsc,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferDOsc,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double max=0,min=0;
      for(int j=(i+period-1); j>i; j--)
        {
         if(j==(i+period-1))
           {
            max=high[j];
            min=low[j];
           }
         else
           {
            if(high[j]>max) max=high[j];
            if(low[j]<min)  min=low[j];
           }
        }
      if(close[i]>max)
        {
         BufferDOsc[i]=close[i]-max;
         BufferColors[i]=0;
        }
      else if(close[i]<min)
        {
         BufferDOsc[i]=close[i]-min;
         BufferColors[i]=1;
        }
      else
        {
         BufferDOsc[i]=0;
         BufferColors[i]=2;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
