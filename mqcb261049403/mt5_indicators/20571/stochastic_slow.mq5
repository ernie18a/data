//+------------------------------------------------------------------+
//|                                              Stochastic_Slow.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic Slow"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot K
#property indicator_label1  "SSD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "SSDS"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodK     =  5;    // Period K
input uint     InpPeriodD     =  5;    // Period D
input uint     InpPeriodS     =  3;    // Slowing
input double   InpOverbought  =  80.0; // Overbought
input double   InpOversold    =  20.0; // Oversold
//--- indicator buffers
double         BufferD[];
double         BufferDS[];
double         BufferK[];
//--- global variables
double         overbought;
double         oversold;
int            period_k;
int            period_d;
int            period_s;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<2 ? 2 : InpPeriodD);
   period_s=int(InpPeriodS<2 ? 2 : InpPeriodS);
   oversold=(InpOversold<0 ? 0 : InpOversold> 99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferK,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SStochastic("+(string)period_k+","+(string)period_d+","+(string)period_s+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferDS,true);
   ArraySetAsSeries(BufferK,true);
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
   if(rates_total<period_k) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_k-1;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=Highest(period_k,i);
      int bl=Lowest(period_k,i);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double min=close[i]-low[bl];
      double max=high[bh]-low[bl];
      BufferK[i]=(max>0 ? (min/max)*100.0 : 50.0);
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_d,BufferK,BufferD);  
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_s,BufferD,BufferDS);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Low           |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
