//+------------------------------------------------------------------+
//|                                                         NRMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "NRMA (Nick Rypoсk Moving Average) indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot NRMA
#property indicator_label1  "NRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot UP
#property indicator_label2  "Bearish NRTR"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "Bullish NRTR"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input double   InpK        =  1.0;  // K
input uint     InpSmooth   =  3;    // Smooth
input double   InpFast     =  2.0;  // Fast
input double   InpSharp    =  2.0;  // Sharp
//--- indicator buffers
double         BufferNRMA[];
double         BufferUP[];
double         BufferDN[];
double         BufferTrend[];
double         BufferNRTR[];
double         BufferOscil[];
double         BufferAvgOscil[];
//--- global variables
double         F;
double         K;
double         fast;
double         sharp;
int            smooth;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   smooth=int(InpSmooth<2 ? 2 : InpSmooth);
   sharp=InpSharp;
   fast=InpFast;
   K=InpK;
   F=2.0/(1.0+fast);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferNRMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTrend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferNRTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferOscil,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgOscil,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,158);
   PlotIndexSetInteger(2,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"NRMA ("+DoubleToString(K,1)+","+(string)smooth+","+DoubleToString(fast,1)+","+DoubleToString(sharp,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferNRMA,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferNRTR,true);
   ArraySetAsSeries(BufferOscil,true);
   ArraySetAsSeries(BufferAvgOscil,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferNRMA,0);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferTrend,0);
      ArrayInitialize(BufferNRTR,0);
      ArrayInitialize(BufferOscil,0);
      ArrayInitialize(BufferAvgOscil,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         if(close[i]>open[i])
           {
            BufferTrend[i]=1;
            BufferNRTR[i]=close[i]*(1.0-K/100.0);
            BufferDN[i]=BufferNRTR[i];
           }
         else
           {
            BufferTrend[i]=-1;
            BufferNRTR[i]=close[i]*(1.0+K/100.0);
            BufferUP[i]=BufferNRTR[i];
           }
        }
      else
        {
         if(BufferTrend[i+1]>0)
           {
            if(close[i]<BufferNRTR[i+1])
              {
               BufferTrend[i]=-1;
               BufferNRTR[i]=close[i]*(1.0+K/100.0);
               BufferUP[i]=BufferNRTR[i];
              }
            else
              {
               BufferTrend[i]=1;
               if(close[i]*(1.0-K/100.0)>BufferNRTR[i+1])
                 {
                  BufferNRTR[i]=close[i]*(1.0-K/100.0);
                 }
               else
                 {
                  BufferNRTR[i]=BufferNRTR[i+1];
                 }
               BufferDN[i]=BufferNRTR[i];
              }
           }
         else
           {
            if(close[i]>BufferNRTR[i+1])
              {
               BufferTrend[i]=1;
               BufferNRTR[i]=close[i]*(1.0-K/100.0);
               BufferDN[i]=BufferNRTR[i];
              }
            else
              {
               BufferTrend[i]=-1.;
               if(close[i]*(1.0+K/100.0)<BufferNRTR[i+1])
                 {
                  BufferNRTR[i]=close[i]*(1.0+K/100.0);
                 }
               else
                 {
                  BufferNRTR[i]=BufferNRTR[i+1];
                 }
               BufferUP[i]=BufferNRTR[i];
              }
           }
        }

      BufferOscil[i]=100.0*fabs(close[i]-BufferNRTR[i])/(K*close[i]);
     }

//--- Расчёт индикатора
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,smooth,BufferOscil,BufferAvgOscil)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double NRatio=pow(BufferAvgOscil[i],sharp);
      BufferNRMA[i]=BufferNRMA[i+1]+NRatio*F*(close[i]-BufferNRMA[i+1]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
