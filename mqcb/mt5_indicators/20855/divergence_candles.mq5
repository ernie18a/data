//+------------------------------------------------------------------+
//|                                           Divergence_Candles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Divergence Candles"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot ArrUP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ArrDN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BufferArrUP[];
double         BufferArrDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArrUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArrDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Divergence Candles");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArrUP,true);
   ArraySetAsSeries(BufferArrDN,true);
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
      limit=rates_total-2;
      ArrayInitialize(BufferArrUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrDN,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(high[i]>high[i+1] && close[i]<=close[i+1])
         BufferArrDN[i]=high[i];
      else
         BufferArrDN[i]=EMPTY_VALUE;

      if(low[i]<low[i+1] && close[i]>=close[i+1])
         BufferArrUP[i]=low[i];
      else
         BufferArrUP[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
