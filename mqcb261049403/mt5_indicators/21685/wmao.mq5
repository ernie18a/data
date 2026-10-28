//+------------------------------------------------------------------+
//|                                                         WMAO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wilders Moving Average Oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot WMAO
#property indicator_label1  "WMAO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriodFast     =  5;             // Fast WMA period
input uint                 InpPeriodSlow     =  20;            // Slow WMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // WMA applied price
//--- indicator buffers
double         BufferWMAO[];
double         BufferColors[];
double         BufferMA1[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferWMAFast[];
double         BufferWMASlow[];
//--- global variables
double         kf;
double         ks;
int            period_fast;
int            period_slow;
int            period_max;
int            handle_ma1;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_max=fmax(period_fast,period_slow);
   kf=1.0/(double)period_fast;
   ks=1.0/(double)period_slow;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWMAO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferWMAFast,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferWMASlow,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wilders OsWMA ("+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWMAO,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferWMAFast,true);
   ArraySetAsSeries(BufferWMASlow,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_SMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferWMAO,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferWMAFast,0);
      ArrayInitialize(BufferWMASlow,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //--- расчёт Fast и Slow WMA
      if(i==rates_total-period_max-2)
        {
         BufferWMAFast[i]=BufferFMA[i];
         BufferWMASlow[i]=BufferSMA[i];
        }
      else
        {
         BufferWMAFast[i]=(BufferMA1[i]-BufferWMAFast[i+1])*kf+BufferWMAFast[i+1];
         BufferWMASlow[i]=(BufferMA1[i]-BufferWMASlow[i+1])*ks+BufferWMASlow[i+1];
        }
      //--- Расчёт Osc WMA
      BufferWMAO[i]=BufferWMAFast[i]-BufferWMASlow[i];
      BufferColors[i]=(BufferWMAO[i]>BufferWMAO[i+1] ? 0 : BufferWMAO[i]<BufferWMAO[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
