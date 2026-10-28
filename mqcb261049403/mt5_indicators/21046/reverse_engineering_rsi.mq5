//+------------------------------------------------------------------+
//|                                      Reverse_Engineering_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Reverse Engineering RSI"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot ReRSI
#property indicator_label1  "RE RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlueViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodRSI      =  14;            // RSI period
input uint                 InpPeriodMA       =  45;            // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferReRSI[];
double         BufferMA[];
double         BufferRSI[];
double         BufferUP[];
double         BufferDN[];
double         BufferAvgRSI[];
double         BufferAvgUP[];
double         BufferAvgDN[];
//--- global variables
int            period_rsi;
int            period_ma;
int            period_exp;
int            weight_sum;
int            handle_ma;
int            handle_rsi;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_exp=2*period_rsi-1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferReRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ReEngineering RSI ("+(string)period_rsi+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferReRSI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferAvgRSI,true);
   ArraySetAsSeries(BufferAvgUP,true);
   ArraySetAsSeries(BufferAvgDN,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
      limit=rates_total-2;
      ArrayInitialize(BufferReRSI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferAvgRSI,0);
      ArrayInitialize(BufferAvgUP,0);
      ArrayInitialize(BufferAvgDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferMA[i]>BufferMA[i+1])
        {
         BufferUP[i]=BufferMA[i]-BufferMA[i+1];
         BufferDN[i]=0.;
        }
      else
        {
         BufferUP[i]=0.;
         BufferDN[i]=BufferMA[i+1]-BufferMA[i];
        }
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_exp,BufferUP,BufferAvgUP);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_exp,BufferDN,BufferAvgDN);
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_exp,period_ma,BufferRSI,BufferAvgRSI);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_exp,period_ma,BufferRSI,BufferAvgRSI);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_exp,period_ma,BufferRSI,BufferAvgRSI,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_ma,BufferRSI,BufferAvgRSI);                    break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AUC_MA=BufferAvgUP[i];
      double ADC_MA=BufferAvgDN[i];
      double RSI_MA=BufferAvgRSI[i];
      double x=(RSI_MA!=100 ? (period_rsi-1.0)*(ADC_MA*RSI_MA/(100.0-RSI_MA)-AUC_MA) : 0);
      BufferReRSI[i]=(x>=0 || RSI_MA==0 ? BufferMA[i]+x : BufferMA[i]+x*(100.0-RSI_MA)/RSI_MA);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
