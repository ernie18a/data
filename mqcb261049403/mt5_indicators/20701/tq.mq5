//+------------------------------------------------------------------+
//|                                                           TQ.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Quality oscillator"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   2
//--- plot TQ
#property indicator_label1  "TQuality"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot TQ
#property indicator_label2  "TCorrection"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodFast     =  7;             // Period fast
input uint                 InpPeriodSlow     =  14;            // Period slow
input uint                 InpPeriodST       =  5;             // Scalar trend period
input uint                 InpPeriodSN       =  250;           // Scalar noise period
input uint                 InpCorrection     =  2;             // Scalar correction factor
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTQ[];
double         BufferColors[];
double         BufferT[];
double         BufferSMA[];
double         BufferFEMA[];
double         BufferSEMA[];
double         BufferReversals[];
double         BufferCPC[];
double         BufferTrend[];
double         BufferDT[];
double         BufferAVG[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_st;
int            period_sn;
int            correction;
int            handle_fema;
int            handle_sema;
int            handle_sma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_st=int(InpPeriodST<1 ? 1 : InpPeriodST);
   period_sn=int(InpPeriodSN<2 ? 2 : InpPeriodSN);
   correction=int(InpCorrection<1 ? 1 : InpCorrection);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTQ,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferT,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferFEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferReversals,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferCPC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferTrend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferDT,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferAVG,INDICATOR_CALCULATIONS);
//--- setting plot buffer and indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Quality ("+(string)period_fast+","+(string)period_slow+","+(string)period_st+","+(string)period_sn+","+(string)correction+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTQ,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferT,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferFEMA,true);
   ArraySetAsSeries(BufferSEMA,true);
   ArraySetAsSeries(BufferReversals,true);
   ArraySetAsSeries(BufferCPC,true);
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferDT,true);
   ArraySetAsSeries(BufferAVG,true);
//--- create MA's handle
   ResetLastError();
   handle_fema=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_EMA,InpAppliedPrice);
   if(handle_fema==INVALID_HANDLE)
     {
      Print("The Fast iMA(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sema=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_EMA,InpAppliedPrice);
   if(handle_sema==INVALID_HANDLE)
     {
      Print("The Slow iMA(",(string)period_slow,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;

      ArrayInitialize(BufferTQ,EMPTY_VALUE);
      ArrayInitialize(BufferT,EMPTY_VALUE);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferFEMA,0);
      ArrayInitialize(BufferSEMA,0);
      ArrayInitialize(BufferReversals,0);
      ArrayInitialize(BufferCPC,0);
      ArrayInitialize(BufferTrend,0);
      ArrayInitialize(BufferDT,0);
      ArrayInitialize(BufferAVG,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fema,0,0,count,BufferFEMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sema,0,0,count,BufferSEMA);
   if(copied!=count) return 0;
   //---
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferT[i]=(BufferFEMA[i]>BufferSEMA[i] ? 1 : -1);
      BufferReversals[i]=BufferFEMA[i]-BufferSEMA[i];
      if(BufferReversals[i]*BufferReversals[i+1]<=0)
         BufferCPC[i]=BufferTrend[i]=0;
      else
        {
         BufferCPC[i]=BufferCPC[i+1]+(BufferSMA[i]-BufferSMA[i+1]);
         BufferTrend[i]=BufferCPC[i]/(period_st)+BufferTrend[i+1]*(1.0-1.0/(period_st));
        }
      BufferDT[i]=(BufferCPC[i]-BufferTrend[i])*(BufferCPC[i]-BufferTrend[i]);
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sn,BufferDT,BufferAVG);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Noise=sqrt(BufferAVG[i]);
      BufferTQ[i]=(Noise!=0.0 ? correction*BufferTrend[i]/Noise : 0);
      BufferColors[i]=(BufferTQ[i]<BufferTQ[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
