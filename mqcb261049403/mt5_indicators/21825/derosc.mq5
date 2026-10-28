//+------------------------------------------------------------------+
//|                                                       DEROSC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Derivative Oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot DEROSC
#property indicator_label1  "Derivative"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrYellowGreen,clrRed,clrOrange,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriodRSI      =  14;            // RSI period
input uint                 InpPeriodEMA1     =  5;             // First EMA period
input uint                 InpPeriodEMA2     =  3;             // Second EMA period
input uint                 InpPeriodSMA      =  9;             // SMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDEROSC[];
double         BufferColors[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferSMA[];
double         BufferRSI[];
//--- global variables
int            period_rsi;
int            period_ema1;
int            period_ema2;
int            period_sma;
int            handle_rsi;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_ema1=int(InpPeriodEMA1<2 ? 2 : InpPeriodEMA1);
   period_ema2=int(InpPeriodEMA2<2 ? 2 : InpPeriodEMA2);
   period_sma=int(InpPeriodSMA<2 ? 2 : InpPeriodSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDEROSC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferEMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Derivative Oscillator ("+(string)period_rsi+","+(string)period_ema1+","+(string)period_ema2+","+(string)period_sma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDEROSC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferRSI,true);
//--- create MA's handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_sma,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDEROSC,EMPTY_VALUE);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferRSI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;

   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_rsi,period_ema1,BufferRSI,BufferEMA1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_ema1,period_ema2,BufferEMA1,BufferEMA2)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ema2,period_sma,BufferEMA2,BufferSMA)==0)
      return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDEROSC[i]=(BufferEMA2[i]-BufferSMA[i])/Point();
      BufferColors[i]=
        (
         BufferDEROSC[i]>0 ? 
         BufferDEROSC[i]>BufferDEROSC[i+1] ? 0 : 1 :
         BufferDEROSC[i]<0 ? 
         BufferDEROSC[i]<BufferDEROSC[i+1] ? 2 : 3 : 4
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
