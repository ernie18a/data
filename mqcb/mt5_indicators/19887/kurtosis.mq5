//+------------------------------------------------------------------+
//|                                                     Kurtosis.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Kurtosis
#property indicator_label1  "Kurtosis"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Momentum
#property indicator_label2  "Momentum"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot RAW
#property indicator_label3  "RAW"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot MA
#property indicator_label4  "MA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint                 InpPeriod         =  4;             // Period of momentum
input uint                 InpPeriodSmooth1  =  66;            // Primary smoothing period
input uint                 InpPeriodSmooth2  =  3;             // Secondary smoothing period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferKurtosis[];
double         BufferMomentum[];
double         BufferRAW[];
double         BufferMA[];
double         BufferSmooth[];
//--- global variables
int            handle_ma;
int            period_momentum;
int            period_smooth1;
int            period_smooth2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_momentum=int(InpPeriod<1 ? 1 : InpPeriod);
   period_smooth1=int(InpPeriodSmooth1<1 ? 1 : InpPeriodSmooth1);
   period_smooth2=int(InpPeriodSmooth2<1 ? 1 : InpPeriodSmooth2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferKurtosis,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMomentum,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSmooth,INDICATOR_CALCULATIONS);
//--- settings plot index label and indicators parameters
   PlotIndexSetString(0,PLOT_LABEL,"Kurtosis("+(string)period_momentum+")");
   IndicatorSetString(INDICATOR_SHORTNAME,"Kurtosis("+(string)period_momentum+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferKurtosis,true);
   ArraySetAsSeries(BufferMomentum,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferSmooth,true);
//--- create handle MA
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period_momentum || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_momentum-1;
      ArrayInitialize(BufferKurtosis,0);
      ArrayInitialize(BufferMomentum,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferSmooth,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit==0 ? 1 : rates_total);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0; i--)
     {
      BufferMomentum[i]=BufferMA[i]-BufferMA[i+period_momentum];
      BufferRAW[i]=(BufferMomentum[i]-BufferMomentum[i+1])/Point();
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_smooth1,BufferRAW,BufferSmooth);
//--- Расчёт индикатора
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_smooth2,BufferSmooth,BufferKurtosis);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
