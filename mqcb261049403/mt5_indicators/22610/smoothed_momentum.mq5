//+------------------------------------------------------------------+
//|                                            Smoothed_Momentum.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed Momentum indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot SM
#property indicator_label1  "SMomentum"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriod         =  12;            // Momentum period
input ENUM_INPUT_YES_NO    InpUseSmoothing   =  INPUT_YES;     // Use smoothing
input uint                 InpPeriodSm       =  20;            // Smoothing period
input ENUM_MA_METHOD       InpMethodSm       =  MODE_SMA;      // Smoothing method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferSM[];
double         BufferMom[];
double         BufferMA[];
//--- global variables
int            period_mom;
int            period_sm;
int            handle_ma;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_mom=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpPeriodSm<2 ? 2 : InpPeriodSm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMom,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed Momentum ("+(string)period_mom+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,(InpUseSmoothing ? 2*period_mom+period_sm*2 : 0));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSM,true);
   ArraySetAsSeries(BufferMom,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA handle
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_mom,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_mom-1;
      ArrayInitialize(BufferSM,0);
      ArrayInitialize(BufferMom,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   if(!InpUseSmoothing)
     {
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferSM[i]=(BufferMA[i]!=0 ? 100.0*BufferMA[i]/BufferMA[i+period_mom] : 0);
      return rates_total;
     }
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMom[i]=(BufferMA[i]!=0 ? 100.0*BufferMA[i]/BufferMA[i+period_mom] : 0);
   if(InpUseSmoothing)
     {
      switch(InpMethodSm)
        {
         case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferMom,BufferSM);
         case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferMom,BufferSM);
         case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferMom,BufferSM,weight_sum);
         //---MODE_SMA
         default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferMom,BufferSM);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
