//+------------------------------------------------------------------+
//|                                                           EF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ehlers Filter indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot EF
#property indicator_label1  "EF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  C'143,188,139'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input uint                 InpMomentum       =  5;             // Momentum
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferEF[];
double         BufferMA[];
double         BufferCoeff[];
double         BufferPriceCoeff[];
double         BufferCoeffAVG[];
double         BufferPriceCoeffAVG[];
//--- global variables
int            period_ind;
int            momentum;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   momentum=int(InpMomentum<1 ? 1 : InpMomentum);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferEF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferCoeff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPriceCoeff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferCoeffAVG,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPriceCoeffAVG,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Ehlers Filter ("+(string)period_ind+","+(string)momentum+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferEF,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferCoeff,true);
   ArraySetAsSeries(BufferPriceCoeff,true);
   ArraySetAsSeries(BufferCoeffAVG,true);
   ArraySetAsSeries(BufferPriceCoeffAVG,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-momentum-1;
      ArrayInitialize(BufferEF,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferCoeff,0);
      ArrayInitialize(BufferPriceCoeff,0);
      ArrayInitialize(BufferCoeffAVG,0);
      ArrayInitialize(BufferPriceCoeffAVG,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCoeff[i]=fabs(BufferMA[i]-BufferMA[i+momentum]);
      BufferPriceCoeff[i]=BufferCoeff[i]*BufferMA[i];
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferCoeff,BufferCoeffAVG);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferPriceCoeff,BufferPriceCoeffAVG);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AvgCoeff=BufferCoeffAVG[i];
      BufferEF[i]=(BufferPriceCoeffAVG[i]/(AvgCoeff!=0 ? AvgCoeff : 1.0));
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
