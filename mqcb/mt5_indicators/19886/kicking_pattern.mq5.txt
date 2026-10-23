//+------------------------------------------------------------------+
//|                                              Kicking_Pattern.mq5 |
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
#property indicator_label1  "Bullish"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bearish
#property indicator_label2  "Bearish"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpShowBullish =  INPUT_YES;  // Show bullish patterns
input ENUM_INPUT_YES_NO InpShowBearish =  INPUT_YES;  // Show bearish patterns
//--- indicator buffers
double         BufferBullish[];
double         BufferBearish[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBullish,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBearish,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBullish,true);
   ArraySetAsSeries(BufferBearish,true);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Kicking pattern");
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-4;
      ArrayInitialize(BufferBullish,EMPTY_VALUE);
      ArrayInitialize(BufferBearish,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Расчёт индикатора
   for(int i=limit; i>0; i--)
     {
      if(InpShowBullish)
        {
         if(close[i]>open[i] && close[i+1]<open[i+1] && close[i+2]>open[i+2] && close[i+3]<open[i+3])
            BufferBullish[i]=high[i];
         else
            BufferBullish[i]=EMPTY_VALUE;
        }
      if(InpShowBearish)
        {
         if(close[i]<open[i] && close[i+1]>open[i+1] && close[i+2]<open[i+2] && close[i+3]>open[i+3])
            BufferBearish[i]=low[i];
         else
            BufferBearish[i]=EMPTY_VALUE;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
