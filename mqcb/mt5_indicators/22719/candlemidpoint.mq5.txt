//+------------------------------------------------------------------+
//|                                               CandleMidPoint.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Candle's Middle Point indicator"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MidPoint
#property indicator_label1  "Middle Point"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_CANDLE_TYPE
  {
   TYPE_CANDLE_HL,      // Candle
   TYPE_CANDLE_OC       // Body
  };
//---
enum ENUM_ARROW_TYPE
  {
   TYPE_ARROW_DOT0      =  158,  // Smallest Dot
   TYPE_ARROW_DOT1      =  159,  // Small Dot
   TYPE_ARROW_DOT2      =  108,  // Big Dot
   TYPE_ARROW_SQUARE1   =  167,  // Small Square
   TYPE_ARROW_SQUARE2   =  110,  // Big Square
   TYPE_ARROW_DIAMOND1  =  115,  // Small Diamond
   TYPE_ARROW_DIAMOND2  =  116,  // Big Diamond
   TYPE_ARROW_CROSS     =  251   // Cross
  };
//--- input parameters
input ENUM_CANDLE_TYPE  InpTypeCandle     =  TYPE_CANDLE_HL;   // Middle point for
input ENUM_ARROW_TYPE   InpTypeArrow      =  TYPE_ARROW_DOT1;  // Dots type
//--- indicator buffers
double         BufferMP[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   //arrow_code=(uchar)InpTypeArrow;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMP,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,(int)InpTypeArrow);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CandleMidPoint");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMP,true);
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
   if(rates_total<1) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMP,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMP[i]=(InpTypeCandle==TYPE_CANDLE_OC ? (open[i]+close[i])/2.0 : (high[i]+low[i])/2.0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
