//+------------------------------------------------------------------+
//|                                                Normalized_AC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Normalized Acceleration/Deceleration indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot AC
#property indicator_label1  "AC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodFastMA   =  5;    // Fast MA period
input uint     InpPeriodSlowMA   =  35;   // Slow MA period
input uint     InpPeriodSM       =  5;    // Smoothing period
input uint     InpNormLevel      =  50;   // Normalization level
input uint     InpScale          =  300;  // Scale
input uint     InpPeriodNorm     =  0;    // Normalization period
//--- indicator buffers
double         BufferAC[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferAO[];
double         BufferMA[];
double         BufferRawAC[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sm;
int            period_max;
int            handle_fma;
int            handle_sma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   period_sm=int(InpPeriodSM<2 ? 2 : InpPeriodSM);
   period_max=fmax(period_sm,fmax(period_fma,period_sma));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRawAC,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized Acceleration/Deceleration ("+(string)period_fma+","+(string)period_sma+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffers parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAC,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferAO,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferRawAC,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,MODE_SMA,PRICE_MEDIAN);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,MODE_SMA,PRICE_MEDIAN);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferAC,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferAO,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferRawAC,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferAO[i]=BufferFMA[i]-BufferSMA[i];
   
   SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_sm,BufferAO,BufferMA);
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRawAC[i]=BufferAO[i]-BufferMA[i];

//--- Расчёт индикатора
   int bl=WRONG_VALUE,bh=WRONG_VALUE;
   double scale=0,max=0,min=0,abs_min=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int num=int(InpPeriodNorm==0 ? rates_total-period_max-4 : InpPeriodNorm);
      bl=ArrayMinimum(BufferRawAC,0,num);
      bh=ArrayMaximum(BufferRawAC,0,num);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      min=BufferRawAC[bl];
      max=BufferRawAC[bh];
      scale=(InpScale==0 ? max-min : InpScale);
      abs_min=fabs(max);
      BufferAC[i]=InpNormLevel+BufferRawAC[i]*(scale/(abs_min!=0 ? abs_min : 1.0));
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
