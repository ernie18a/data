//+------------------------------------------------------------------+
//|                                          Trailing_Stop_Level.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trailing Stop level indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot LevUP
#property indicator_label1  "Level for short"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LevDN
#property indicator_label2  "Level for long"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input double   InpPercent  =  30; // Percent
//--- indicator buffers
double         BufferLevUP[];
double         BufferLevDN[];
double         BufferData[];
//--- global variables
double         percent;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   percent=(InpPercent<1 ? 1 : InpPercent/100.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLevUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLevDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferData,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TrailingStopLevel("+DoubleToString(percent,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLevUP,true);
   ArraySetAsSeries(BufferLevDN,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferLevUP,EMPTY_VALUE);
      ArrayInitialize(BufferLevDN,EMPTY_VALUE);
      ArrayInitialize(BufferData,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double loss=close[i]*percent/100;
      if(close[i]>BufferData[i+1] && close[i+1]>BufferData[i+1])
        {
         BufferData[i]=fmax(BufferData[i+1],close[i]-loss);
         BufferLevDN[i]=BufferData[i];
         BufferLevDN[i+1]=BufferData[i+1];
        }
      else
        {
         if(close[i]<BufferData[i+1] && close[i+1]<BufferData[i+1])
           {
            BufferData[i]=fmin(BufferData[i+1],close[i]+loss);
            BufferLevUP[i]=BufferData[i];
            BufferLevUP[i+1]=BufferData[i+1];
           }
         else
           {
            if(close[i]>BufferData[i+1])
              {
               BufferData[i]=close[i]-loss;
               BufferLevDN[i]=BufferData[i];
               BufferLevUP[i+1]=BufferData[i+1];
              }
            else
              {
               BufferData[i]=close[i]+loss;
               BufferLevUP[i]=BufferData[i];
               BufferLevDN[i+1]=BufferData[i+1];
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
