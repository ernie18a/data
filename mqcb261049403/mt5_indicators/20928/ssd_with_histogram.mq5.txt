//+------------------------------------------------------------------+
//|                                           SSD_With_Histogram.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "SSD with histogram indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot K
#property indicator_label1  "Stoch"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrChocolate
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot H
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input uint           InpPeriodK     =  5;             // %K period
input uint           InpPeriodD     =  3;             // %D period
input uint           InpSlowing     =  3;             // Slowing
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;      // Method
input ENUM_STO_PRICE InpPriceField  =  STO_LOWHIGH;   // Price field
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferH[];
double         BufferColors[];
double         BufferSTO[];
//--- global variables
int            period_k;
int            period_d;
int            slowing;
int            weight_sum;
int            handle_sto;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<2 ? 2 : InpSlowing);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferH,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferSTO,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SSDH ("+(string)period_k+","+(string)period_d+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSTO,true);
//--- create Stochastic's handle
   ResetLastError();
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,slowing,InpMethod,InpPriceField);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k,",",(string)period_d,",",(string)slowing,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferH,0);
      ArrayInitialize(BufferSTO,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferSTO);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferK[i]=BufferSTO[i]-50.0;
   SimpleMAOnBuffer(rates_total,prev_calculated,period_k+slowing,period_d,BufferK,BufferD);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferH[i]=BufferK[i]-BufferD[i];
      BufferColors[i]=(BufferH[i]<BufferH[i+1] ? 1 : 0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
