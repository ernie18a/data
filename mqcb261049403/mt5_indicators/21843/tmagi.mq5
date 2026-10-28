//+------------------------------------------------------------------+
//|                                                        TMAGi.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "TMAGi oscillator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot B1
#property indicator_label1  "TSMAGi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot B2
#property indicator_label2  "TLWMAGi"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodADX      =  14;            // ADX period
input uint                 InpPeriodFast     =  8;             // Fast MA period
input uint                 InpPeriodMiddle   =  16;            // Middle MA period
input uint                 InpPeriodSlow     =  25;            // Slow MA period
input uint                 InpSlowingSMA     =  3;             // SMA slowing
input uint                 InpSlowingLWMA    =  8;             // LWMA slowing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferB1[];
double         BufferB2[];
double         BufferRAW[];
double         BufferADXP[];
double         BufferADXM[];
double         BufferFMA[];
double         BufferMMA[];
double         BufferSMA[];
//--- global variables
int            period_adx;
int            period_fma;
int            period_mma;
int            period_sma;
int            smooth_sma;
int            smooth_lwma;
int            period_max;
int            weight_sum;
int            handle_fma;
int            handle_mma;
int            handle_sma;
int            handle_adx;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_mma=int(InpPeriodMiddle<1 ? 1 : InpPeriodMiddle);
   period_sma=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   smooth_sma=int(InpSlowingSMA<1 ? 1 : InpSlowingSMA);
   smooth_lwma=int(InpSlowingLWMA<1 ? 1 : InpSlowingLWMA);
   period_max=fmax(period_fma,fmax(period_mma,fmax(period_sma,fmax(smooth_sma,smooth_lwma))));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferB1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferB2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRAW,INDICATOR_DATA);
   SetIndexBuffer(3,BufferADXP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferADXM,INDICATOR_DATA);
   SetIndexBuffer(5,BufferFMA,INDICATOR_DATA);
   SetIndexBuffer(6,BufferMMA,INDICATOR_DATA);
   SetIndexBuffer(7,BufferSMA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TMAGi ("+(string)period_adx+","+(string)period_fma+","+(string)period_mma+","+(string)period_sma+","+(string)smooth_sma+","+(string)smooth_lwma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferADXP,true);
   ArraySetAsSeries(BufferADXM,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferMMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,MODE_SMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mma=iMA(NULL,PERIOD_CURRENT,period_mma,0,MODE_SMA,InpAppliedPrice);
   if(handle_mma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_mma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferB1,EMPTY_VALUE);
      ArrayInitialize(BufferB2,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferADXP,0);
      ArrayInitialize(BufferADXM,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferMMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mma,0,0,count,BufferMMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferADXP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferADXM);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double di=BufferADXP[i]-BufferADXM[i];
      BufferRAW[i]=(fabs(BufferFMA[i]-BufferMMA[i])+fabs(BufferFMA[i]-BufferSMA[i])+fabs(BufferMMA[i]-BufferSMA[i]))*di;
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_max,smooth_sma,BufferRAW,BufferB1)==0)
      return 0;
   if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,smooth_lwma,BufferRAW,BufferB2,weight_sum)==0)
      return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
