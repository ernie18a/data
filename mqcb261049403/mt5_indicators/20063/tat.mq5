//+------------------------------------------------------------------+
//|                                                          TAT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot TAT
#property indicator_label1  "TAT"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SIG
#property indicator_label2  "SIG"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodFastMACD =  12;      // MACD Fast EMA period
input uint     InpPeriodSlowMACD =  26;      // MACD Slow EMA period
input uint     InpPeriodSigMACD  =  9;       // MACD Signal MA period
input double   InpStepSAR        =  0.02;    // SAR step
input double   InpMaxSAR         =  0.2;     // SAR max
input double   InpMultMACD       =  66.67;   // MACD multiplier
input double   InpMultSAR        =  6.67;    // SAR multiplier
input uint     InpPeriodSigTAT   =  12;      // TAT Signal period
input double   InpOverbought     =  10.0;    // TAT overbought
input double   InpOversold       = -10.0;    // TAT oversold
//--- indicator buffers
double         BufferTAT[];
double         BufferSIG[];
double         BufferLong[];
double         BufferAF[];
double         BufferExtr[];
double         BufferSAR[];
double         BufferMACD[];
double         BufferSIG_MACD[];
//--- global variables
int            period_sig_tat;
int            period_sig_macd;
int            period_fast;
int            period_slow;
int            handle_macd;
double         sar_step;
double         sar_max;
double         overbought;
double         oversold;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFastMACD<1 ? 1 : InpPeriodFastMACD);
   period_slow=int(InpPeriodSlowMACD<1 ? 1 : InpPeriodSlowMACD);
   period_sig_macd=int(InpPeriodSigMACD<1 ? 1 : InpPeriodSigMACD);
   period_sig_tat=int(InpPeriodSigTAT<1 ? 1 : InpPeriodSigTAT);
   sar_step=InpStepSAR;
   sar_max=InpMaxSAR;
   overbought=(fabs(InpOverbought)<0.001 ? 0.001 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.001 ? -0.001 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTAT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSIG,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLong,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferExtr,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSAR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMACD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSIG_MACD,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TAT");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTAT,true);
   ArraySetAsSeries(BufferSIG,true);
   ArraySetAsSeries(BufferLong,true);
   ArraySetAsSeries(BufferAF,true);
   ArraySetAsSeries(BufferExtr,true);
   ArraySetAsSeries(BufferSAR,true);
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSIG_MACD,true);
//--- create handle MACD
   ResetLastError();
   handle_macd=iMACD(NULL,PERIOD_CURRENT,period_fast,period_slow,period_sig_macd,PRICE_CLOSE);
   if(handle_macd==INVALID_HANDLE)
     {
      Print("The iMACD(",(string)period_fast,",",(string)period_slow,",",(string)period_sig_macd,") object was not created: Error ",GetLastError());
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
   int max=fmax(period_fast,fmax(period_slow,fmax(period_sig_tat,period_sig_macd)));
   if(rates_total<max+period_sig_macd+2) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int total=rates_total-period_sig_macd-max-2;
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=total;
      ArrayInitialize(BufferTAT,0);
      ArrayInitialize(BufferSIG,0);
      ArrayInitialize(BufferLong,0);
      ArrayInitialize(BufferAF,0);
      ArrayInitialize(BufferExtr,0);
      ArrayInitialize(BufferSAR,0);
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferSIG_MACD,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_macd,MAIN_LINE,0,count,BufferMACD);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_macd,SIGNAL_LINE,0,count,BufferSIG_MACD);
   if(copied!=count) return 0;
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==total)
        {
         BufferLong[i]=1;
         BufferAF[i]=sar_step;
         BufferExtr[i]=high[i];
         BufferSAR[i]=low[i];
        }
      else
        {
         BufferLong[i]=BufferLong[i+1];
         BufferAF[i]=BufferAF[i+1];
         BufferExtr[i]=BufferExtr[i+1];
         BufferSAR[i]=BufferSAR[i+1]+BufferAF[i+1]*(BufferExtr[i+1]-BufferSAR[i+1]);
         if(BufferLong[i+1]==1)
           {
            if(low[i]<BufferSAR[i])
              {
               BufferLong[i]=0;
               BufferAF[i]=sar_step;
               BufferSAR[i]=BufferExtr[i+1];
               BufferExtr[i]=low[i];
              }
            else
              {
               if(BufferExtr[i+1]<high[i])
                 {
                  BufferExtr[i]=high[i];
                  BufferAF[i]=BufferAF[i+1]+sar_step;
                  if(BufferAF[i]>sar_max) BufferAF[i]=sar_max;
                 }
              }
           }
         else
           {
            if(high[i]>BufferSAR[i])
              {
               BufferLong[i]=1;
               BufferAF[i]=sar_step;
               BufferSAR[i]=BufferExtr[i+1];
               BufferExtr[i]=high[i];
              }
            else
              {
               if(BufferExtr[i+1]>low[i])
                 {
                  BufferExtr[i]=low[i];
                  BufferAF[i]=BufferAF[i+1]+sar_step;
                  if(BufferAF[i]>sar_max) BufferAF[i]=sar_max;
                 }
              }
           }
        }
     }
//--- Расчёт индикатора
   double tat_sar=0;
   double tat_macd=0;
   for(int i=limit; i>=0; i--)
     {
      tat_sar=(close[i]-BufferSAR[i])/(BufferSAR[i]>0 ? BufferSAR[i] : DBL_MIN);
      tat_macd=(BufferMACD[i]-BufferSIG_MACD[i])/close[i];
      BufferTAT[i]=50*(tat_sar*InpMultSAR+tat_macd*InpMultMACD);
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig_tat,BufferTAT,BufferSIG);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
