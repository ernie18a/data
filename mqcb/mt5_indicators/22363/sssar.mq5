//+------------------------------------------------------------------+
//|                                                        SSSAR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Single Stream SAR"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot Up
#property indicator_label1  "SAR Bearish"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot Dn
#property indicator_label2  "SAR Bullish"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5
//--- input parameters
input double   InpStep  =  0.02; // Step
input double   InpMax   =  0.2;  // Maximum
//--- indicator buffers
double         BufferBullish[];
double         BufferBearish[];
double         BufferTradeHigh[];
double         BufferTradeLow[];
double         BufferPosition[];
double         BufferParOp[];
double         BufferAF[];
double         BufferSAR[];
//--- global variables
double         step;
double         max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   step=(InpStep<0.0001 ? 0.0001 : InpStep);
   max=(InpMax<0.0001 ? 0.0001 : InpMax);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBearish,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBullish,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTradeHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferTradeLow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferPosition,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferParOp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSAR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SSSAR ("+DoubleToString(step,2)+","+DoubleToString(max,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBearish,true);
   ArraySetAsSeries(BufferBullish,true);
   ArraySetAsSeries(BufferTradeHigh,true);
   ArraySetAsSeries(BufferTradeLow,true);
   ArraySetAsSeries(BufferPosition,true);
   ArraySetAsSeries(BufferParOp,true);
   ArraySetAsSeries(BufferAF,true);
   ArraySetAsSeries(BufferSAR,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferBearish,EMPTY_VALUE);
      ArrayInitialize(BufferBullish,EMPTY_VALUE);
      ArrayInitialize(BufferTradeHigh,0);
      ArrayInitialize(BufferTradeLow,0);
      ArrayInitialize(BufferPosition,0);
      ArrayInitialize(BufferParOp,0);
      ArrayInitialize(BufferAF,0);
      ArrayInitialize(BufferSAR,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferTradeHigh[i]=high[i+1];
         BufferTradeLow[i]=low[i+1];
         BufferPosition[i]=-1;
         BufferParOp[i]=high[i+1];
         BufferAF[i]=0;
        }
      else
        {
         BufferParOp[i]=BufferParOp[i+1];
         BufferPosition[i]=BufferPosition[i+1];
         BufferTradeHigh[i]=BufferTradeHigh[i+1];
         BufferTradeLow[i]=BufferTradeLow[i+1];
         BufferAF[i]=BufferAF[i+1];
        }
      if(high[i]>BufferTradeHigh[i])
        {
         BufferTradeHigh[i]=high[i];
        }
      if(low[i]<BufferTradeLow[i])
        {
         BufferTradeLow[i]=low[i];
        }

      if(BufferPosition[i]==1)
        {
         if(low[i]<BufferParOp[i])
           {
            BufferPosition[i]=-1;
            BufferSAR[i]=BufferTradeHigh[i];
            BufferTradeHigh[i]=high[i];
            BufferTradeLow[i]=low[i];
            BufferAF[i]=step;
            BufferParOp[i]=BufferSAR[i]+BufferAF[i]*(BufferTradeLow[i]-BufferSAR[i]);
            if(BufferParOp[i]<high[i])
              {
               BufferParOp[i]=high[i];
              }
            if(BufferParOp[i]<high[i+1])
              {
               BufferParOp[i]=high[i+1];
              }
           }
         else
           {
            BufferSAR[i]=BufferParOp[i];
            if(BufferTradeHigh[i]>BufferTradeHigh[i+1] && BufferAF[i]<max)
              {
               BufferAF[i]=BufferAF[i]+step;
               if(BufferAF[i]>max)
                 {
                  BufferAF[i]=max;
                 }
              }
            BufferParOp[i]=BufferSAR[i]+BufferAF[i]*(BufferTradeHigh[i]-BufferSAR[i]);
            if(BufferParOp[i]>low[i])
              {
               BufferParOp[i]=low[i];
              }
            if(BufferParOp[i]>low[i+1])
              {
               BufferParOp[i]=low[i+1];
              }
           }
        }
      else
        {
         if(high[i]>BufferParOp[i])
           {
            BufferPosition[i]=1;
            BufferSAR[i]=BufferTradeLow[i];
            BufferTradeHigh[i]=high[i];
            BufferTradeLow[i]=low[i];
            BufferAF[i]=step;
            BufferParOp[i]=BufferSAR[i]+BufferAF[i]*(BufferTradeHigh[i]-BufferSAR[i]);
            if(BufferParOp[i]>low[i])
              {
               BufferParOp[i]=low[i];
              }
            if(BufferParOp[i]>low[i+1])
              {
               BufferParOp[i]=low[i+1];
              }
           }
         else
           {
            BufferSAR[i]=BufferParOp[i];
            if(BufferTradeLow[i]<BufferTradeLow[i+1] && BufferAF[i]<max)
              {
               BufferAF[i]=BufferAF[i]+step;
               if(BufferAF[i]>max)
                 {
                  BufferAF[i]=max;
                 }
              }
            BufferParOp[i]=BufferSAR[i]+BufferAF[i]*(BufferTradeLow[i]-BufferSAR[i]);
            if(BufferParOp[i]<high[i])
              {
               BufferParOp[i]=high[i];
              }
            if(BufferParOp[i]<high[i+1])
              {
               BufferParOp[i]=high[i+1];
              }
           }
        }

      if(BufferPosition[i]==1)
        {
         BufferBullish[i]=BufferSAR[i];
         BufferBearish[i]=EMPTY_VALUE;
        }
      else
        {
         BufferBearish[i]=BufferSAR[i];
         BufferBullish[i]=EMPTY_VALUE;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
