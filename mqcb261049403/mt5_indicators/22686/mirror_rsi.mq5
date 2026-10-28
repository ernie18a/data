//+------------------------------------------------------------------+
//|                                                   Mirror_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Mirror RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot RSI1
#property indicator_label1  "Ascending"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot RSI2
#property indicator_label2  "Descending"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Signal
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriodRSI1     =  20;            // First RSI period
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;   // First RSI applied price
input uint                 InpPeriodRSI2     =  20;            // Second RSI period
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_OPEN;    // Second RSI applied price
input uint                 InpPeriodSig      =  20;            // Signal period
input ENUM_MA_METHOD       InpMethodSig      =  MODE_SMA;      // Signal method
//--- indicator buffers
double         BufferDiff1[];
double         BufferDiff2[];
double         BufferSignal[];
double         BufferRSI1[];
double         BufferRSI2[];
//--- global variables
int            period_sig;
int            period_rsi1;
int            period_rsi2;
int            period_max;
int            handle_rsi1;
int            handle_rsi2;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi1=int(InpPeriodRSI1<2 ? 2 : InpPeriodRSI1);
   period_rsi2=int((InpPeriodRSI2==period_rsi1 && InpAppliedPrice2==InpAppliedPrice1) ? period_rsi1+1 : InpPeriodRSI2<2 ? 2 : InpPeriodRSI2);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_max=(int)fmax(period_rsi1,period_rsi2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDiff1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDiff2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRSI1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRSI2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Mirror RSI ("+(string)period_rsi1+","+(string)period_rsi2+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   for(int i=0;i<3;i++)
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDiff1,true);
   ArraySetAsSeries(BufferDiff2,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferRSI1,true);
   ArraySetAsSeries(BufferRSI2,true);
//--- create RSI's handles
   ResetLastError();
   handle_rsi1=iRSI(NULL,PERIOD_CURRENT,period_rsi1,InpAppliedPrice1);
   if(handle_rsi1==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi2=iRSI(NULL,PERIOD_CURRENT,period_rsi2,InpAppliedPrice2);
   if(handle_rsi2==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi2,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_sig,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferDiff1,0);
      ArrayInitialize(BufferDiff2,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferRSI1,0);
      ArrayInitialize(BufferRSI2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi1,0,0,count,BufferRSI1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_rsi2,0,0,count,BufferRSI2);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDiff1[i]=BufferRSI1[i]-BufferRSI2[i];
      BufferDiff2[i]=BufferRSI2[i]-BufferRSI1[i];
     }
   switch(InpMethodSig)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferDiff1,BufferSignal);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferDiff1,BufferSignal);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferDiff1,BufferSignal,weight_sum);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferDiff1,BufferSignal);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
