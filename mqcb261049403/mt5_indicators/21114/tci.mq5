//+------------------------------------------------------------------+
//|                                                          TCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trading Channel Index indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot TPI
#property indicator_label1  "TChannel Idx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input uint                 InpPeriodAVG      =  21;            // Average period
input double               InpCoeff          =  0.015;         // Coefficient
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTCI[];
double         BufferMA1[];
double         BufferMAP[];
double         BufferRAW1[];
double         BufferRAW2[];
double         BufferAvgRAW[];
//--- global variables
double         coeff;
int            period_tpi;
int            period_avg;
int            handle_ma1;
int            handle_maP;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tpi=int(InpPeriod<2 ? 2 : InpPeriod);
   period_avg=int(InpPeriodAVG<2 ? 2 : InpPeriodAVG);
   coeff=(InpCoeff==0 ? 0.0001 : InpCoeff);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRAW1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRAW2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trading Channel Index ("+(string)period_tpi+","+(string)period_avg+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTCI,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferRAW1,true);
   ArraySetAsSeries(BufferRAW2,true);
   ArraySetAsSeries(BufferAvgRAW,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_tpi,0,MODE_EMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_tpi,") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTCI,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferRAW1,0);
      ArrayInitialize(BufferRAW2,0);
      ArrayInitialize(BufferAvgRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW1[i]=fabs(BufferMA1[i]-BufferMAP[i]);
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_tpi,BufferRAW1,BufferAvgRAW)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW2[i]=(BufferAvgRAW[i]!=0 ? (BufferMA1[i]-BufferMAP[i])/(coeff*BufferAvgRAW[i]) : 0);

//--- Расчёт индикатора
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_avg,BufferRAW2,BufferTCI)==0)
      return 0;
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
