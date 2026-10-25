//+------------------------------------------------------------------+
//|                                                   MACD_Osmax.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MACD OsmaX oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot Line
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MACD
#property indicator_label3  "OsMA"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrBlue,clrRed,clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  8
//--- input parameters
input uint                 InpPeriodFast     =  12;            // Fast EMA period
input uint                 InpPeriodSlow     =  26;            // Slow EMA period
input uint                 InpPeriodSig      =  9;             // Signal period
input uint                 InpOsmaX          =  2;             // OsmaX
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSignal[];
double         BufferOsMA[];
double         BufferColors[];
double         BufferFMA[];
double         BufferSMA[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_sig;
int            osma;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<3 ? 3 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<3 ? 3 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   osma=int(InpOsmaX<1 ? 1 : InpOsmaX);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOsMA,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD OsmaX ("+(string)period_fast+","+(string)period_slow+","+(string)period_sig+","+(string)osma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferOsMA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create MA handle
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_EMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA (",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_EMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA (",(string)period_slow,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_sig,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sig-2;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferOsMA,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMACD[i]=BufferFMA[i]-BufferSMA[i];
      BufferSignal[i]=EMA(rates_total,BufferMACD[i],BufferSignal[i+1],period_sig,i);
      BufferOsMA[i]=(BufferMACD[i]-BufferSignal[i])*osma;
      BufferColors[i]=
        (
         BufferMACD[i]>BufferMACD[i+1] ? (BufferOsMA[i]>BufferOsMA[i+1] ? 0 : 2) :
         BufferMACD[i]<BufferMACD[i+1] ? (BufferOsMA[i]<BufferOsMA[i+1] ? 1 : 2) : 2
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double EMA(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+2.0/(1+period)*(price-prev));
  }
//+------------------------------------------------------------------+
