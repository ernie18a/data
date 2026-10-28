//+------------------------------------------------------------------+
//|                                                        SSIFT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed Stochastic Inverse Fisher Transform"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot IFT
#property indicator_label1  "IFT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot RBW
#property indicator_label2  "RBW"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  30;            // Period
input uint                 InpSlowing        =  5;             // Slowing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferIFT[];
double         BufferRBW[];
double         BufferMA[];
double         BufferMAA[];
double         BufferRainbow[];
double         BufferStoch[];
//--- global variables
int            period_ind;
int            slowing;
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
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIFT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRBW,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRainbow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferStoch,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SSIFT("+(string)period_ind+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIFT,true);
   ArraySetAsSeries(BufferRBW,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMAA,true);
   ArraySetAsSeries(BufferRainbow,true);
   ArraySetAsSeries(BufferStoch,true);
//--- create MA's handle
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<11) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-11;
      ArrayInitialize(BufferIFT,EMPTY_VALUE);
      ArrayInitialize(BufferRBW,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMAA,0);
      ArrayInitialize(BufferRainbow,0);
      ArrayInitialize(BufferStoch,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRainbow[i]=(20*BufferMA[i]+75*BufferMA[i+1]+180*BufferMA[i+2]+336*BufferMA[i+3]+463*BufferMA[i+4]+462*BufferMA[i+5]+330*BufferMA[i+6]+165*BufferMA[i+7]+55*BufferMA[i+8]+11*BufferMA[i+9]+BufferMA[i+10])/2098;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double min=BufferRainbow[ArrayMinimum(BufferRainbow,i,period_ind)];
      double max=BufferRainbow[ArrayMaximum(BufferRainbow,i,period_ind)];
      double val=max-min;
      BufferStoch[i]=100*(BufferRainbow[i]-min)/(val!=0 ? val : DBL_MIN);
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferStoch,BufferMAA);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRBW[i]=BufferMAA[i];//iMAOnArray(Stoch,0,Slowing,0,MODE_SMA,pos);
      double x=(BufferRBW[i]-50)/5;
      BufferIFT[i]=((exp(x)-1)/(exp(x)+1)+1)*50;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
