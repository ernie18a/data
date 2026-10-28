//+------------------------------------------------------------------+
//|                                                      Coppock.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Coppock indicator by Edwin Sedgwick Coppock"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Coppock
#property indicator_label1  "Coppock Indicator"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOliveGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input uint                 InpPeriodROC1     =  14;            // Period ROC 1
input uint                 InpPeriodROC2     =  11;            // Period ROC 2
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferCoppock[];
double         BufferMAROC[];
double         BufferFastROC[];
double         BufferSlowROC[];
double         BufferROC[];
//--- global variables
int            period_ind;
int            period_froc;
int            period_sroc;
int            handle_mar;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   period_froc=int(InpPeriodROC1<1 ? 1 : InpPeriodROC1);
   period_sroc=int(InpPeriodROC2<1 ? 1 : InpPeriodROC2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCoppock,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAROC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferFastROC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSlowROC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferROC,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Coppock("+(string)period_ind+","+(string)period_froc+","+(string)period_sroc+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCoppock,true);
   ArraySetAsSeries(BufferMAROC,true);
   ArraySetAsSeries(BufferFastROC,true);
   ArraySetAsSeries(BufferSlowROC,true);
   ArraySetAsSeries(BufferROC,true);
//--- create MA's handle
   ResetLastError();
   handle_mar=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_mar==INVALID_HANDLE)
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=fmax(period_ind,fmax(period_froc,period_sroc));
   if(rates_total<max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-1;
      ArrayInitialize(BufferCoppock,EMPTY_VALUE);
      ArrayInitialize(BufferMAROC,0);
      ArrayInitialize(BufferFastROC,0);
      ArrayInitialize(BufferSlowROC,0);
      ArrayInitialize(BufferROC,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_mar,0,0,count,BufferMAROC);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferFastROC[i]=(BufferMAROC[i]/(BufferMAROC[i+period_froc]!=0 ? BufferMAROC[i+period_froc] : 1)-1)*100;
      BufferSlowROC[i]=(BufferMAROC[i]/(BufferMAROC[i+period_sroc]!=0 ? BufferMAROC[i+period_sroc] : 1)-1)*100;
      BufferROC[i]=BufferFastROC[i]+BufferSlowROC[i];
     }
//--- Расчёт индикатора
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferROC,BufferCoppock,weight_sum);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
