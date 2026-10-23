//+------------------------------------------------------------------+
//|                                             Delta_oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Delta oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Delta
#property indicator_label1  "Delta Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         BufferOSC[];
double         BufferColors[];
double         BufferPrice[];
double         BufferDelta[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOSC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDelta,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Delta Oscillator");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOSC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferDelta,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOSC,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferDelta,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPrice[i]=(open[i]+high[i]+low[i]+close[i])/4.0;
      if(BufferPrice[i]>0 && BufferPrice[i+1]>0)
         BufferDelta[i]=BufferPrice[i]+log10(BufferPrice[i+1]/BufferPrice[i]);
      BufferOSC[i]=(BufferDelta[i]!=0 ? BufferPrice[i]-BufferDelta[i] : EMPTY_VALUE);
      BufferColors[i]=(BufferOSC[i]>BufferOSC[i+1] ? 0 : BufferOSC[i]<BufferOSC[i+1] ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
