//+------------------------------------------------------------------+
//|                                             Small_Inside_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Bullish
#property indicator_label1  "Bearish"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Bearish
#property indicator_label2  "Bullish"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- indicator buffers
double         BufferBearish[];
double         BufferBullish[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBearish,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBullish,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Small inside bar");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBullish,true);
   ArraySetAsSeries(BufferBearish,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferBullish,EMPTY_VALUE);
      ArrayInitialize(BufferBearish,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool bull_flag=false;
      bool bear_flag=false;
      double ratio=0;
      if(high[i]-low[i]==0) ratio=10; else ratio=(high[i+1]-low[i+1])/(high[i]-low[i]);
      if(high[i]<high[i+1] && low[i]>low[i+1] && ratio>2)
        {
         if(close[i]>open[i]&& high[i]<(high[i+1]+low[i+1])/2 && close[i+1]<open[i+1]) bull_flag=true;
         if(close[i]<open[i] && low[i]<(high[i+1]+low[i+1])/2 && close[i+1]>open[i+1]) bear_flag=true;
        }
      if(bull_flag) BufferBullish[i]=low[i]; else BufferBullish[i]=EMPTY_VALUE;
      if(bear_flag) BufferBearish[i]=high[i]; else BufferBearish[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
