//+------------------------------------------------------------------+
//|                                                 Reverse_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Reverse MACD oscillator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_METHOD
  {
   METHOD_SMA  =  MODE_SMA,   // Simple
   METHOD_EMA  =  MODE_EMA    // Exponential
  };
//--- input parameters
input uint                 InpPeriodFastMA      =12;              // MACD Fast MA period
input uint                 InpPeriodSlowMA      =26;              // MACD Slow MA period
input uint                 InpPeriodSignal      =9;               // MACD Signal line period
input ENUM_METHOD          InpMethod            =  METHOD_EMA;    // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSignal[];
double         BufferHist[];
double         BufferMA1[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferRawMACD[];
double         BufferRawMacdAVG[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sig;
int            period_max;
int            handle_ma1;
int            handle_fma;
int            handle_sma;
double         ax;
double         ay;
double         az;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA==period_fma ? period_fma+1 : InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   period_sig=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
   period_max=fmax(period_sig,fmax(period_fma,period_sma));
   ax=2.0/(1.0+period_fma);
   ay=2.0/(1.0+period_sma);
   az=2.0/(1.0+period_sig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferFMA,INDICATOR_DATA);
   SetIndexBuffer(5,BufferSMA,INDICATOR_DATA);
   SetIndexBuffer(6,BufferRawMACD,INDICATOR_DATA);
   SetIndexBuffer(7,BufferRawMacdAVG,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Reverse MACD ("+(string)period_fma+","+(string)period_sma+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferRawMACD,true);
   ArraySetAsSeries(BufferRawMacdAVG,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,(ENUM_MA_METHOD)InpMethod,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,(ENUM_MA_METHOD)InpMethod,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   if(InpMethod==METHOD_SMA)
     {
      handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
      if(handle_ma1==INVALID_HANDLE)
        {
         Print("The iMA(1) object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
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
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferRawMACD,0);
      ArrayInitialize(BufferRawMacdAVG,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   if(InpMethod==METHOD_SMA)
     {
      copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
      if(copied!=count) return 0;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRawMACD[i]=BufferFMA[i]-BufferSMA[i];

   switch(InpMethod)
     {
      case METHOD_SMA : SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferRawMACD,BufferRawMacdAVG);      break;
      //---METHOD_EMA
      default         : ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferRawMACD,BufferRawMacdAVG); break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double signal=BufferRawMacdAVG[i];
      switch(InpMethod)
        {
         case METHOD_SMA :
           BufferMACD[i]=(period_fma*BufferMA1[i+period_sma-1]-period_sma*BufferMA1[i+period_fma-1])/(period_fma-period_sma);
           BufferSignal[i]=(period_fma*period_sma*(BufferFMA[i]-BufferSMA[i])+period_fma*BufferMA1[i+period_sma-1]-period_sma*BufferMA1[i+period_fma-1])/(period_fma-period_sma);
           BufferHist[i]=((period_fma*period_sma*period_sig-period_fma*period_sma)*BufferRawMACD[i]-period_fma*period_sma*period_sig*signal-(period_sma*period_sig-period_sma)*BufferMA1[i+period_fma-1]+(period_fma*period_sig-period_fma)*BufferMA1[i+period_sma-1]+period_fma*period_sma*BufferRawMACD[i+period_sig-1])/(period_fma*period_sig-period_sma*period_sig-period_fma+period_sma);
           break;
         //---METHOD_EMA
         default:
           BufferMACD[i]=(ax*BufferFMA[i]-ay*BufferSMA[i])/(ax-ay);
           BufferSignal[i]=((1.0-ay)*BufferSMA[i]-(1.0-ax)*BufferFMA[i])/(ax-ay);
           BufferHist[i]=(signal-(1.0-ax)*BufferFMA[i]+(1.0-ay)*BufferSMA[i])/(ax-ay);
           break;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
