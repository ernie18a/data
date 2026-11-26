//+------------------------------------------------------------------+
//|                                                         WAMI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Momentum Indicator by Anthony W.Warren"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot WAMI
#property indicator_label1  "WAMI"
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
input uint                 InpPeriodMA1      =  4;             // First MA period
input ENUM_MA_METHOD       InpMethodMA1      =  MODE_SMA;      // First MA method
input uint                 InpPeriodMA2      =  13;            // Second MA period
input ENUM_MA_METHOD       InpMethodMA2      =  MODE_SMA;      // Second MA method
input uint                 InpPeriodMA3      =  13;            // Third MA period
input ENUM_MA_METHOD       InpMethodMA3      =  MODE_SMA;      // Third MA method
input uint                 InpPeriodSig      =  4;             // Signal MA period
input ENUM_MA_METHOD       InpMethodSig      =  MODE_SMA;      // Signal MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferWAMI[];
double         BufferSignal[];
double         BufferMA[];
double         BufferDiff[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferMA3[];
double         BufferSigMA[];
//--- global variables
int            period_ma1;
int            period_ma2;
int            period_ma3;
int            period_sig;
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
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   period_ma3=int(InpPeriodMA3<2 ? 2 : InpPeriodMA3);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_max=fmax(period_ma1,fmax(period_ma2,fmax(period_ma3,period_sig)));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWAMI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSigMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Warren Momentum ("+(string)period_ma1+","+(string)period_ma2+","+(string)period_ma3+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWAMI,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferMA3,true);
   ArraySetAsSeries(BufferSigMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<period_max || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferWAMI,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferMA3,0);
      ArrayInitialize(BufferSigMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDiff[i]=BufferMA[i]-BufferMA[i+1];
     }
   switch(InpMethodMA1)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferDiff,BufferMA1);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferDiff,BufferMA1);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferDiff,BufferMA1,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferDiff,BufferMA1);                    break;
     }
   switch(InpMethodMA2)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferMA1,BufferMA2);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferMA1,BufferMA2);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferMA1,BufferMA2,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferMA1,BufferMA2);                    break;
     }
   switch(InpMethodMA3)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma2,period_ma3,BufferMA2,BufferMA3);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma2,period_ma3,BufferMA2,BufferMA3);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma2,period_ma3,BufferMA2,BufferMA3,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ma2,period_ma3,BufferMA2,BufferMA3);                    break;
     }
   switch(InpMethodSig)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma3,period_sig,BufferMA3,BufferSigMA);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma3,period_sig,BufferMA3,BufferSigMA);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma3,period_sig,BufferMA3,BufferSigMA,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ma3,period_sig,BufferMA3,BufferSigMA);                    break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferWAMI[i]=BufferMA3[i]/Point();
      BufferSignal[i]=BufferSigMA[i]/Point();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

   