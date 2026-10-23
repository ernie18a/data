//+------------------------------------------------------------------+
//|                                               Speed_of_trade.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Speed of trade indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot ToUP
#property indicator_label1  "Upwards"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ToDN
#property indicator_label2  "Downwards"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  14;   // Period
input double   InpMultiplier  =  2.0;  // Multiplier
//--- indicator buffers
double         BufferToUP[];
double         BufferToDN[];
double         BufferSoT[];
double         BufferAVG[];
//--- global variables
int            period_ind;
double         multiplier;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   multiplier=(InpMultiplier<0.01 ? 0.01 : InpMultiplier);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferToUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferToDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSoT,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAVG,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Speed of trade ("+(string)period_ind+","+DoubleToString(InpMultiplier,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferToUP,true);
   ArraySetAsSeries(BufferToDN,true);
   ArraySetAsSeries(BufferSoT,true);
   ArraySetAsSeries(BufferAVG,true);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferToUP,EMPTY_VALUE);
      ArrayInitialize(BufferToDN,EMPTY_VALUE);
      ArrayInitialize(BufferSoT,0);
      ArrayInitialize(BufferAVG,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSoT[i]=(tick_volume[i]!=0 ? ((close[i]-open[i])/tick_volume[i])*1000000000 : 0);
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferSoT,BufferAVG);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AVG=BufferAVG[i]*multiplier;
      if(BufferSoT[i]<AVG)
        {
         BufferToUP[i]=EMPTY_VALUE;
         BufferToDN[i]=EMPTY_VALUE;
        }
      else
        {
         if(close[i]>open[i])
           {
            BufferToDN[i]=EMPTY_VALUE;
            BufferToUP[i]=high[i];
           }
         if(close[i]<open[i])
           {
            BufferToDN[i]=low[i];
            BufferToUP[i]=EMPTY_VALUE;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
