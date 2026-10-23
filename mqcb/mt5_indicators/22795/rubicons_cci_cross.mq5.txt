//+------------------------------------------------------------------+
//|                                           Rubicons_CCI_Cross.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Rubicons CCI Cross signal oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot CCI
#property indicator_label1  "CCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot EMA
#property indicator_label2  "EMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SigUP
#property indicator_label3  "Up Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot SigDN
#property indicator_label4  "Down Signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpPeriodCCI   =  10;      // CCI period
input uint     InpPeriodEMA   =  3;       // EMA period
input double   InpOverbought  =  100.0;   // Overbought
input double   InpOversold    = -100.0;   // Oversold
//--- indicator buffers
double         BufferCCI[];
double         BufferEMA[];
double         BufferSigUP[];
double         BufferSigDN[];
//--- global variables
double         overbought;
double         oversold;
int            period_cci;
int            period_ema;
int            period_max;
int            handle_cci;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_ema=int(InpPeriodEMA<1 ? 1 : InpPeriodEMA);
   period_max=fmax(period_cci,period_ema);
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : InpOverbought>100.0 ? 100.0 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold)<-100.0 ? -100.0 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferEMA,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSigUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSigDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,241);
   PlotIndexSetInteger(3,PLOT_ARROW,242);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Rubicons CCI Cross ("+(string)period_cci+","+(string)period_ema+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
//PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferEMA,true);
   ArraySetAsSeries(BufferSigUP,true);
   ArraySetAsSeries(BufferSigDN,true);
//--- create cci handle
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferSigUP,EMPTY_VALUE);
      ArrayInitialize(BufferSigDN,EMPTY_VALUE);
      ArrayInitialize(BufferEMA,0);
     }

//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   ResetLastError();
   int copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_cci,period_ema,BufferCCI,BufferEMA)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSigUP[i]=BufferSigDN[i]=EMPTY_VALUE;
      if(BufferCCI[i+1]<oversold && BufferCCI[i]>oversold && BufferEMA[i]<BufferCCI[i])
         BufferSigUP[i]=oversold-40.0;
      if(BufferCCI[i+1]>overbought && BufferCCI[i]<overbought && BufferEMA[i]>BufferCCI[i])
         BufferSigDN[i]=overbought+40.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
