//+------------------------------------------------------------------+
//|                                                         VAMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Velocity and Acceleration Moving Average"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot VAMA
#property indicator_label1  "VAMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriod         =  15;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_INPUT_YES_NO    InpDoubleSmooth   =  INPUT_YES;     // Double smoothing
//--- indicator buffers
double         BufferVAMA[];
double         BufferMA[];
double         BufferRAW[];
//--- global variables
int            period_ind;
int            period_max;
int            weight_sum;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_max=period_ind/4;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVAMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRAW,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Velocity and Acceleration MA ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVAMA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ind,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ind,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferVAMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA0=BufferMA[i];
      double MA4=BufferMA[i+period_ind/4];
      double MA8=BufferMA[i+period_ind/8];
      double MA12=BufferMA[i+period_ind/12];
      double vel=MA0-MA4;
      double acc=MA0-2.0*MA4+MA8;
      double aaa=MA0-3.0*MA4+3.0*MA8-MA12;
      BufferRAW[i]=MA0+vel+acc/2.0+aaa/6.0;
      if(!InpDoubleSmooth)
         BufferVAMA[i]=BufferRAW[i];
     }
//--- Расчёт индикатора
   if(InpDoubleSmooth)
     {
      int n=period_ind+period_ind/4+period_ind/8+period_ind/12;
      return(ExponentialMAOnBuffer(rates_total,prev_calculated,n,period_ind/4,BufferRAW,BufferVAMA));
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
