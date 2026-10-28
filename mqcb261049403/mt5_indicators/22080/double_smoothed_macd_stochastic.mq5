//+------------------------------------------------------------------+
//|                              Double_Smoothed_MACD_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Double smoothed MACD Stochastic oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot DSS
#property indicator_label1  "DSS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodSto      =  32;            // Stochastic period
input uint                 InpPeriodSm       =  9;             // Smoothing
input uint                 InpPeriodSig      =  5;             // Signal period
input uint                 InpPeriodFast     =  12;            // Fast EMA period
input uint                 InpPeriodSlow     =  26;            // Slow EMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferDSS[];
double         BufferSignal[];
double         BufferDDS2[];
double         BufferMACD[];
double         BufferFMA[];
double         BufferSMA[];
//--- global variables
double         overbought;
double         oversold;
double         alpha;
double         beta;
int            period_sto;
int            period_sm;
int            period_sig;
int            period_fast;
int            period_slow;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sto=int(InpPeriodSto<2 ? 2 : InpPeriodSto);
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
   alpha=2.0/(1.0+period_sig);
   beta=2.0/(1.0+period_sm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDDS2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMACD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed MACD Stochastic ("+(string)period_sto+","+(string)period_sm+","+(string)period_sig+","+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDSS,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferDDS2,true);
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_EMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_EMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_sto,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sto-2;
      ArrayInitialize(BufferDSS,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferDDS2,0);
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMACD[i]=BufferFMA[i]-BufferSMA[i];
      int bl=ArrayMinimum(BufferMACD,i,period_sto);
      int bh=ArrayMaximum(BufferMACD,i,period_sto);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferMACD[bl];
      double max=BufferMACD[bh];
      double DDS1=(min!=max ? 100.*(BufferMACD[i]-min)/(max-min) : 0);
      BufferDDS2[i]=BufferDDS2[i+1]+beta*(DDS1-BufferDDS2[i+1]);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferDDS2,i,period_sto);
      int bh=ArrayMaximum(BufferDDS2,i,period_sto);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferDDS2[bl];
      double max=BufferDDS2[bh];

      double DDS3=(min!=max ? 100.0*(BufferDDS2[i]-min)/(max-min) : 0);

      BufferDSS[i]=BufferDSS[i+1]+beta*(DDS3-BufferDSS[i+1]);

      BufferSignal[i]=BufferSignal[i+1]+alpha*(BufferDSS[i]-BufferSignal[i+1]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
