//+------------------------------------------------------------------+
//|                                                   AhrensMACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ahrens Moving Average Convergence Divergence"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot Hist
#property indicator_label1  "Ahrens Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDeepSkyBlue,clrDarkOrange,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MACD
#property indicator_label2  "Ahrens MACD"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Signal
#property indicator_label3  "Ahrens Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriodFast  =  12;   // Fast Ahrens MA period
input uint     InpPeriodSlow  =  26;   // Slow Ahrens MA period
input uint     InpPeriodSig   =  9;    // Signal line period
//--- indicator buffers
double         BufferHist[];
double         BufferColors[];
double         BufferMACD[];
double         BufferSignal[];
double         BufferFastAHRMA[];
double         BufferSlowAHRMA[];
double         BufferSignalAHRMA[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_signal;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_signal=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
   period_max=fmax(period_fast,fmax(period_slow,period_signal));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(4,BufferFastAHRMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSlowAHRMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSignalAHRMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Ahrens MACD ("+(string)period_fast+","+(string)period_slow+","+(string)period_signal+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferFastAHRMA,true);
   ArraySetAsSeries(BufferSlowAHRMA,true);
   ArraySetAsSeries(BufferSignalAHRMA,true);
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
   if(rates_total<fmax(period_max+1,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferHist,0);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferFastAHRMA,0);
      ArrayInitialize(BufferSlowAHRMA,0);
      ArrayInitialize(BufferSignalAHRMA,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MedianPrice=(high[i]+low[i])/2.0;
      double MedianMA1=(BufferFastAHRMA[i+1]+BufferFastAHRMA[i+period_fast])/2.0;
      BufferFastAHRMA[i]=BufferFastAHRMA[i+1]+((MedianPrice-MedianMA1)/period_fast);
      //---
      double MedianMA2=(BufferSlowAHRMA[i+1]+BufferSlowAHRMA[i+period_slow])/2.0;
      BufferSlowAHRMA[i]=BufferSlowAHRMA[i+1]+((MedianPrice-MedianMA2)/period_slow);
      BufferMACD[i]=BufferFastAHRMA[i]-BufferSlowAHRMA[i];
      //---
      double MedianMA3=(BufferSignal[i+1]+BufferSignal[i+period_signal])/2.0;
      BufferSignal[i]=  BufferSignal[i+1]+((BufferMACD[i]-MedianMA3)/period_signal);
      BufferHist[i]=BufferMACD[i]-BufferSignal[i];
      BufferColors[i]=(BufferHist[i]>BufferHist[i+1] ? 0 : BufferHist[i]<BufferHist[i+1] ? 1 : 2);
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
