//+------------------------------------------------------------------+
//|                                           SRange_Contraction.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Signal Range Contraction indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot RC
#property indicator_label1  "Range"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrTurquoise
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot C
#property indicator_label2  "Breakout"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_MODE
  {
   MODE_CURRENT,     // Current
   MODE_PREVIOUS     // Previous
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input double            InpThreshold   =  50.0;          // Threshold
input ENUM_INPUT_YES_NO InpShowRC      =  INPUT_YES;     // Show Small Range
input ENUM_MODE         InpMode        =  MODE_CURRENT;  // Calculation period mode
//--- indicator buffers
double         BufferRC[];
double         BufferC[];
//--- global variables
double         threshold;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=(int)InpMode;
   threshold=fabs(InpThreshold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferC,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SRange Contraction ("+DoubleToString(threshold,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Threshold ("+DoubleToString(threshold,2)+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRC,true);
   ArraySetAsSeries(BufferC,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-(2+period);
      ArrayInitialize(BufferRC,EMPTY_VALUE);
      ArrayInitialize(BufferC,EMPTY_VALUE);
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(high[i+1+period]!=low[i+1+period])
         BufferRC[i]=100.*(high[i+period]-low[i+period])/(high[i+1+period]-low[i+1+period]);
      BufferC[i]=(InpShowRC && BufferRC[i]<threshold ? BufferRC[i] : EMPTY_VALUE);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
