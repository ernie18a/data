//+------------------------------------------------------------------+
//|                                                          DMX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bipolar DMI oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot DMX
#property indicator_label1  "DMX"
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
input uint                 InpPeriod         =  14;            // DMX Period
input uint                 InpPeriodSm       =  5;             // Signal period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDMX[];
double         BufferSignal[];
double         BufferDIP[];
double         BufferDIM[];
//--- global variables
int            period_adx;
int            period_smooth;
int            weight_sum;
int            handle_adx;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_adx=int(InpPeriod<1 ? 1 : InpPeriod);
   period_smooth=int(InpPeriodSm<2 ? 2 : InpPeriodSm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDMX,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDIP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDIM,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DMX ("+(string)period_adx+","+(string)period_smooth+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDMX,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferDIP,true);
   ArraySetAsSeries(BufferDIM,true);
//--- create MA's handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferDMX,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferDIP,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferDIP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferDIM);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=BufferDIP[i]+BufferDIM[i];
      BufferDMX[i]=(sum!=0 ? (BufferDIP[i]-BufferDIM[i])/sum : 0);
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferDMX,BufferSignal);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferDMX,BufferSignal);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferDMX,BufferSignal,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferDMX,BufferSignal);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
