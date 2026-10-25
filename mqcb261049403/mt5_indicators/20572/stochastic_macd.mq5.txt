//+------------------------------------------------------------------+
//|                                              Stochastic_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic MACD"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot StoMACD
#property indicator_label1  "StochMACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodFast     =  12;            // MACD Fast MA
input uint                 InpPeriodSlow     =  35;            // MACD Slow MA
input uint                 InpPeriodSig      =  9;             // MACD Signal period
input uint                 InpPeriodSTO      =  18;            // Stoch period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferStoMACD[];
double         BufferMAF[];
double         BufferMAS[];
double         BufferB1[];
double         BufferB2[];
double         BufferMA[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sig;
int            period_sto;
int            handle_fma;
int            handle_sma;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_sma=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_sto=int(InpPeriodSTO<1 ? 1 : InpPeriodSTO);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferStoMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferB1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferB2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAS,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"StochMACD("+(string)period_fma+","+(string)period_sma+","+(string)period_sig+","+(string)period_sto+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferStoMACD,true);
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMAF,true);
   ArraySetAsSeries(BufferMAS,true);
//--- create MA's handle
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethod,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The Fast iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethod,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The Slow iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=fmax(period_fma,fmax(period_sma,period_sig));
   if(rates_total<max) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-1;
      ArrayInitialize(BufferStoMACD,EMPTY_VALUE);
      ArrayInitialize(BufferB1,0);
      ArrayInitialize(BufferB2,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMAF,0);
      ArrayInitialize(BufferMAS,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_fma,0,0,count,BufferMAF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferMAS);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferB1[i]=BufferMAF[i]-BufferMAS[i];
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferB1,BufferMA);                 break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferB1,BufferMA);                    break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferB1,BufferMA,weight_sum);   break;
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferB1,BufferMA);                      break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferB2[i]=BufferB1[i]-BufferMA[i];
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int imin=ArrayMinimum(BufferB2,i,period_sto);
      int imax=ArrayMaximum(BufferB2,i,period_sto);
      if(imin==WRONG_VALUE || imax==WRONG_VALUE)
         continue;
      BufferStoMACD[i]=(BufferB2[imin]!=BufferB2[imax] ? 100*(BufferB1[i]-BufferMA[i]-BufferB2[imin])/(BufferB2[imax]-BufferB2[imin]) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
