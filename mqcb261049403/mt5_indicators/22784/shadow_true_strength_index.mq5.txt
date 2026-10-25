//+------------------------------------------------------------------+
//|                                   Shadow_True_Strength_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Shadow True Strength Index oscillator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   3
//--- plot TSI
#property indicator_label1  "TSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SM1
#property indicator_label2  "Shadow one"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SM2
#property indicator_label3  "Shadow two"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Price source
input uint                 InpPeriodSRC      =  1;             // Price source period
input uint                 InpPeriodSm1      =  7;             // First smoothing period
input uint                 InpPeriodSm2      =  14;            // Second smoothing period
input uint                 InpPeriodSh1      =  14;            // First shadow period
input ENUM_MA_METHOD       InpMethodSh1      =  MODE_SMA;      // First shadow method
input uint                 InpPeriodSh2      =  14;            // Second shadow period
input ENUM_MA_METHOD       InpMethodSh2      =  MODE_SMA;      // Second shadow method
input double               InpOverbought     =  25.0;          // Overbought
input double               InpOversold       = -25.0;          // Oversold
//--- indicator buffers
double         BufferTSI[];
double         BufferSH1[];
double         BufferSH2[];
double         BufferUDM[];
double         BufferADM[];
double         BufferUDM1[];
double         BufferUDM2[];
double         BufferADM1[];
double         BufferADM2[];
double         BufferMA[];
//--- global variables
double         overbought;
double         oversold;
int            period_src;
int            period_sm1;
int            period_sm2;
int            period_sh1;
int            period_sh2;
int            weight_sum1;
int            weight_sum2;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_src=int(InpPeriodSRC<1 ? 1 : InpPeriodSRC);
   period_sm1=int(InpPeriodSm1<2 ? 2 : InpPeriodSm1);
   period_sm2=int(InpPeriodSm2<2 ? 2 : InpPeriodSm2);
   period_sh1=int(InpPeriodSh1<2 ? 2 : InpPeriodSh1);
   period_sh2=int(InpPeriodSh2<2 ? 2 : InpPeriodSh2);
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : InpOverbought>100.0 ? 100.0 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold)<-100.0 ? -100.0 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSH1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSH2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferUDM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferUDM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferUDM2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferADM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferADM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferADM2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Shadow TSI ("+(string)period_src+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sh1+","+(string)period_sh2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTSI,true);
   ArraySetAsSeries(BufferSH1,true);
   ArraySetAsSeries(BufferSH2,true);
   ArraySetAsSeries(BufferUDM,true);
   ArraySetAsSeries(BufferUDM1,true);
   ArraySetAsSeries(BufferUDM2,true);
   ArraySetAsSeries(BufferADM,true);
   ArraySetAsSeries(BufferADM1,true);
   ArraySetAsSeries(BufferADM2,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_src,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_src,") object was not created: Error ",GetLastError());
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
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_src-2;
      ArrayInitialize(BufferTSI,0);
      ArrayInitialize(BufferSH1,EMPTY_VALUE);
      ArrayInitialize(BufferSH2,EMPTY_VALUE);
      ArrayInitialize(BufferUDM,0);
      ArrayInitialize(BufferUDM1,0);
      ArrayInitialize(BufferUDM2,0);
      ArrayInitialize(BufferADM,0);
      ArrayInitialize(BufferADM1,0);
      ArrayInitialize(BufferADM2,0);
      ArrayInitialize(BufferMA,0);
     }

//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUDM[i]=BufferMA[i]-BufferMA[i+1];
      BufferADM[i]=fabs(BufferUDM[i]);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_src,period_sm1,BufferUDM,BufferUDM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_src,period_sm1,BufferADM,BufferADM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_sm1,period_sm2,BufferUDM1,BufferUDM2)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_sm1,period_sm2,BufferADM1,BufferADM2)==0)
      return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTSI[i]=(BufferADM2[i]!=0 ? 100.0*BufferUDM2[i]/BufferADM2[i] : 0);
   
   switch(InpMethodSh1)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sh1,BufferTSI,BufferSH1)==0) return 0;                break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sh1,BufferTSI,BufferSH1)==0) return 0;                   break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sh1,BufferTSI,BufferSH1,weight_sum1)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sh1,BufferTSI,BufferSH1)==0) return 0;                     break;
     }
   switch(InpMethodSh2)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,period_sh1,period_sh2,BufferSH1,BufferSH2);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,period_sh1,period_sh2,BufferSH1,BufferSH2);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_sh1,period_sh2,BufferSH1,BufferSH2,weight_sum2);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,period_sh1,period_sh2,BufferSH1,BufferSH2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
