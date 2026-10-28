//+------------------------------------------------------------------+
//|                                                          DSS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Double Smoothed Stochastic"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot DSS
#property indicator_label1  "DSS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  13;   // Period
input uint     InpPeriodEMA   =  8;    // EMA period
input uint     InpPeriodSig   =  8;    // Signal period
input double   InpOverbought  =  80.0; // Overbought
input double   InpOversold    =  20.0; // Oversold
//--- indicator buffers
double         BufferDSS[];
double         BufferSignal[];
double         BufferRAW[];
//--- global variables
double         overbought;
double         oversold;
double         coeff;
int            period_raw;
int            period_ema;
int            period_sig;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_raw=int(InpPeriod<2 ? 2 : InpPeriod);
   period_ema=int(InpPeriodEMA<2 ? 2 : InpPeriodEMA);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   coeff=2.0/(1.0+period_ema);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DSS ("+(string)period_raw+","+(string)period_ema+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDSS,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferRAW,true);
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
   if(rates_total<fmax(period_raw,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_raw-2;
      ArrayInitialize(BufferDSS,0);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=ArrayMaximum(high,i,period_raw);
      int bl=ArrayMinimum(low,i,period_raw);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=high[bh];
      double min=low[bl];
      double delta=close[i]-min;
      double mit=(max-min!=0 ? delta*100.0/(max-min) : 0);
      BufferRAW[i]=coeff*mit+(1.0-coeff)*BufferRAW[i+1];
      bh=ArrayMaximum(BufferRAW,i,period_raw);
      bl=ArrayMinimum(BufferRAW,i,period_raw);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      max=BufferRAW[bh];
      min=BufferRAW[bl];
      delta=BufferRAW[i]-min;
      mit=(max-min!=0 ? delta*100.0/(max-min) : 0);
      BufferDSS[i]=coeff*mit+(1.0-coeff)*BufferDSS[i+1];
     }
//--- Сигнальная линия
   return(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferDSS,BufferSignal));

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
