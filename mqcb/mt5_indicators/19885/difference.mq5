//+------------------------------------------------------------------+
//|                                                   Difference.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Difference
#property indicator_label1  "Difference"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_METHOD
  {
   METHOD_HIGH_LOW,     // High/Low
   METHOD_OPEN_CLOSE    // Open/Close
  };
//--- input parameters
input uint        InpPeriod   =  10;               // Period
input ENUM_METHOD InpMethod   =  METHOD_HIGH_LOW;  // Calculation method
//--- indicator buffers
double         BufferDifference[];
double         BufferColors[];
double         BufferData[];
//--- global variables
int            period_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   string short_name="Difference("+(string)period_ma+")";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDifference,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferData,INDICATOR_CALCULATIONS);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDifference,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferData,true);
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
   if(rates_total<period_ma || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferDifference,EMPTY_VALUE);
      ArrayInitialize(BufferData,EMPTY_VALUE);
      ArrayInitialize(BufferColors,0);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Подготовка данных
   for(int i=limit; i>=0; i--)
      BufferData[i]=(InpMethod==METHOD_HIGH_LOW ? high[i]-low[i] : close[i]-open[i])/Point();
//--- Расчёт индикатора
   int count=(limit==0 ? 1 : rates_total);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferData,BufferDifference);
   for(int i=limit-1; i>=0; i--)
     {
      if(BufferDifference[i]<BufferDifference[i+1])
         BufferColors[i]=1;
      else
         BufferColors[i]=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
