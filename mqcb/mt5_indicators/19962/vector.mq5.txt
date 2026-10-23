//+------------------------------------------------------------------+
//|                                                       Vector.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot WP
#property indicator_label1  "WP"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot WN
#property indicator_label2  "WN"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input color    InpColorH1  =  clrRed;     // Inertia osc color
input color    InpColorH2  =  clrGreen;   // Trend osc color
//--- indicator buffers
double         BufferWP[];
double         BufferWN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferWN,INDICATOR_DATA);
//--- settings plots parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpColorH1);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpColorH2);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Vector");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWP,true);
   ArraySetAsSeries(BufferWN,true);
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<17) return 0;
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-17;
      ArrayInitialize(BufferWP,0);
      ArrayInitialize(BufferWN,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferWP[i]=close[i]-(close[i+2]+close[i+4]+close[i+8]+close[i+16])/4;
      BufferWN[i]=0.9375*close[i]-0.5*close[i+2]-0.25*close[i+4]-0.125*close[i+8]-0.0625*close[i+16];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
