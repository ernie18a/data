//+------------------------------------------------------------------+
//|                                                          WVF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William's Vix Fix indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot WVF
#property indicator_label1  "WVF"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_DRAWING_STYLE
  {
   STYLE_DRAW_LINE   =  DRAW_COLOR_LINE,     // Line
   STYLE_DRAW_HIST   =  DRAW_COLOR_HISTOGRAM // Histogramm
  };
//--- input parameters
input uint                 InpPeriod      =  22;               // Period
input ENUM_DRAWING_STYLE   InpDrawingType =  STYLE_DRAW_LINE;  // Drawing style
//--- indicator buffers
double         BufferWVF[];
double         BufferColors[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWVF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WVF("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpDrawingType);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWVF,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferWVF,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int h=HighestClose(period,i);
      if(h==WRONG_VALUE) continue;
      double max=close[h];
      BufferWVF[i]=(max>0 ? 100*(max-low[i])/max : 0);
      BufferColors[i]=(BufferWVF[i]>BufferWVF[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии               |
//+------------------------------------------------------------------+
int HighestClose(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyClose(NULL,PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
