//+------------------------------------------------------------------+
//|                                               SuperTrend_Dot.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "SuperTrend Dot indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot TrUP
#property indicator_label1  "Trend Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot TrDN
#property indicator_label2  "Trend Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  10;   // Period
input double   InpMultiplier  =  1.5;  // Multiplier
//--- indicator buffers
double         BufferTrUP[];
double         BufferTrDN[];
double         BufferUP[];
double         BufferDN[];
double         BufferTR[];
double         BufferATR[];
//--- global variables
double         multiplier;
int            period;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   multiplier=(InpMultiplier<0 ? 0 : InpMultiplier);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTrUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTrDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferATR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SuperTrend Dot ("+(string)period+","+DoubleToString(multiplier,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTrUP,true);
   ArraySetAsSeries(BufferTrDN,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferATR,true);
//--- create MA's handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<4)
      return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTrUP,EMPTY_VALUE);
      ArrayInitialize(BufferTrDN,EMPTY_VALUE);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ATR=BufferATR[i];
      double median=(high[i]+low[i])/2.0;

      BufferUP[i]=median+ATR*multiplier;
      BufferDN[i]=median-ATR*multiplier;

      BufferTR[i]=(close[i]>BufferUP[i+1] ? 1 : (close[i]<BufferDN[i+1] ? -1 : BufferTR[i+1]));

      bool flag=(BufferTR[i]<0 && BufferTR[i+1]>0 ? true : false);
      bool flagh=(BufferTR[i]>0 && BufferTR[i+1]<0 ? true : false);
      
      if(BufferTR[i]>0 && BufferDN[i]<BufferDN[i+1])
         BufferDN[i]=BufferDN[i+1];
      if(BufferTR[i]<0 && BufferUP[i]>BufferUP[i+1])
         BufferUP[i]=BufferUP[i+1];

      if(flag)
         BufferUP[i]=median+ATR*multiplier;
      if(flagh)
         BufferDN[i]=median-ATR*multiplier;

      if(BufferTR[i]==1)
        {
         BufferTrUP[i]=BufferDN[i];
         BufferTrDN[i]=EMPTY_VALUE;
        }
      else
        {
         BufferTrDN[i]=BufferUP[i];
         BufferTrUP[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
