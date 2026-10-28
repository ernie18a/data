//+------------------------------------------------------------------+
//|                                              Trend_Component.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "The Trend Component indicator of John Ehlers"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot TC
#property indicator_label1  "TC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  11;            // Period
input double               InpDelta          =  0.05;          // Delta
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTC[];
double         BufferMA[];
double         BufferBP[];
//--- global variables
int            period_ma;
int            handle_ma;
double         delta;
double         alpha;
double         beta;
double         gamma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   delta=InpDelta;
   beta=cos(2.0*M_PI/period_ma);
   gamma=1.0/cos(4.0*M_PI*delta/period_ma);
   alpha=gamma*sqrt(gamma*gamma-1.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferBP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Component ("+(string)period_ma+","+DoubleToString(delta,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTC,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferBP,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<=period_ma*2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferTC,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferBP,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferBP[i]=0.5*(1.0-alpha)*(BufferMA[i]-BufferMA[i+2])+beta*(1.0+alpha)*BufferBP[i+1]-alpha*BufferBP[i+2];
//--- Расчёт индикатора
   SimpleMAOnBuffer(rates_total,prev_calculated,0,2*period_ma+1,BufferBP,BufferTC);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
