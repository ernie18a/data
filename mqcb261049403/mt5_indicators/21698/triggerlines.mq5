//+------------------------------------------------------------------+
//|                                                 Triggerlines.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Triggerlines indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot WT
#property indicator_label1  "WT"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrOrangeRed,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint                 InpPeriod         =  25;            // Period
input uint                 InpPeriodSM       =  13;            // Smoothing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferWT[];
double         BufferColorsWT[];
double         BufferSignal[];
double         BufferColorsSignal[];
double         BufferMA1[];
//--- global variables
double         lv;
int            period1;
int            period_sm;
int            period_max;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpPeriodSM<2 ? 2 : InpPeriodSM);
   period_max=fmax(period1,period_sm);
   lv=(1.0+period1)/3.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsWT,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsSignal,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMA1,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Triggerlines ("+(string)period1+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_sm);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetString(0,PLOT_LABEL,"WT("+(string)period1+")");
   PlotIndexSetString(1,PLOT_LABEL,"Signal("+(string)period_sm+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWT,true);
   ArraySetAsSeries(BufferColorsWT,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferColorsSignal,true);
   ArraySetAsSeries(BufferMA1,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period1-1;
      ArrayInitialize(BufferWT,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferMA1,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA1);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      for(int j=1; j<=period1; j++)
         sum+=(j-lv)*BufferMA1[i+period1-j];
      BufferWT[i]=6.0*sum/(period1*(period1+1.0));
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period1,period_sm,BufferWT,BufferSignal)==0)
      return 0;

//--- Цвет буферов
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferWT[i]>BufferSignal[i])
         BufferColorsSignal[i]=BufferColorsWT[i]=0;
      else if(BufferWT[i]<BufferSignal[i])
         BufferColorsSignal[i]=BufferColorsWT[i]=1;
      else
         BufferColorsSignal[i]=BufferColorsWT[i]=2;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
