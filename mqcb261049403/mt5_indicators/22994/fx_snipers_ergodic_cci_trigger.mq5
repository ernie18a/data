//+------------------------------------------------------------------+
//|                               Fx_Snipers_Ergodic_CCI_Trigger.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fx Sniper's Ergodic CCI Trigger oscillator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   2
//--- plot SESSIT1
#property indicator_label1  "ECCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SESSIT2
#property indicator_label2  "Trigger"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriodQ     =  4;          // Period Q
input uint           InpPeriodR     =  8;          // Period R
input uint           InpPeriodS     =  5;          // Period S
input uint           InpTrigger     =  4;          // Trigger
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;   // Method
input double         InpOverbought  =  150;        // Overbought
input double         InpOversold    = -150;        // Oversold
//--- indicator buffers
double         BufferECCI[];
double         BufferTrigger[];
double         BufferMOM[];
double         BufferAbsMOM[];
double         BufferVar1[];
double         BufferVar2[];
double         BufferVar2a[];
double         BufferVar2b[];
double         BufferVar2c[];
double         BufferVar3[];
//--- global variables
double         overbought;
double         oversold;
int            period_q;
int            period_r;
int            period_s;
int            trigger;
int            period_max;
int            weight_sum1;
int            weight_sum2;
int            weight_sum3;
int            weight_sum4;
int            weight_sum5;
int            weight_sum6;
int            weight_sum7;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_q=int(InpPeriodQ<2 ? 2 : InpPeriodQ);
   period_r=int(InpPeriodR<2 ? 2 : InpPeriodR);
   period_s=int(InpPeriodS<2 ? 2 : InpPeriodS);
   trigger=int(InpTrigger<2 ? 2 : InpTrigger);
   period_max=fmax(trigger,fmax(period_q,fmax(period_r,period_s)));
   overbought=(fabs(InpOverbought)<0.001 ? 0.001 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.001 ? -0.001 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferECCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTrigger,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMOM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAbsMOM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVar1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVar2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferVar2a,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferVar2b,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferVar2c,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferVar3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fx Sniper's Ergodic CCI Trigger ("+(string)period_q+","+(string)period_r+","+(string)period_s+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferECCI,true);
   ArraySetAsSeries(BufferTrigger,true);
   ArraySetAsSeries(BufferMOM,true);
   ArraySetAsSeries(BufferAbsMOM,true);
   ArraySetAsSeries(BufferVar1,true);
   ArraySetAsSeries(BufferVar2,true);
   ArraySetAsSeries(BufferVar2a,true);
   ArraySetAsSeries(BufferVar2b,true);
   ArraySetAsSeries(BufferVar2c,true);
   ArraySetAsSeries(BufferVar3,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferECCI,0);
      ArrayInitialize(BufferTrigger,0);
      ArrayInitialize(BufferMOM,0);
      ArrayInitialize(BufferAbsMOM,0);
      ArrayInitialize(BufferVar1,0);
      ArrayInitialize(BufferVar2,0);
      ArrayInitialize(BufferVar2a,0);
      ArrayInitialize(BufferVar2b,0);
      ArrayInitialize(BufferVar2c,0);
      ArrayInitialize(BufferVar3,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMOM[i]=close[i]-close[i+1];
      BufferAbsMOM[i]=fabs(BufferMOM[i]);
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferMOM,BufferVar1)==0) return 0;                           
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar1,BufferVar2)==0) return 0;
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2,BufferVar2c)==0) return 0;
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferAbsMOM,BufferVar2a)==0) return 0;
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar2a,BufferVar2b)==0) return 0;
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2b,BufferVar3)==0) return 0;
         break;
      case MODE_SMMA :
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferMOM,BufferVar1)==0) return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar1,BufferVar2)==0) return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2,BufferVar2c)==0) return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferAbsMOM,BufferVar2a)==0) return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar2a,BufferVar2b)==0) return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2b,BufferVar3)==0) return 0;
         break;
      case MODE_LWMA :
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferMOM,BufferVar1,weight_sum1)==0) return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar1,BufferVar2,weight_sum2)==0) return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2,BufferVar2c,weight_sum3)==0) return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferAbsMOM,BufferVar2a,weight_sum4)==0) return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar2a,BufferVar2b,weight_sum5)==0) return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2b,BufferVar3,weight_sum6)==0) return 0;
         break;
      //---MODE_SMA
      default        :
         if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferMOM,BufferVar1)==0) return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar1,BufferVar2)==0) return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2,BufferVar2c)==0) return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_q,BufferAbsMOM,BufferVar2a)==0) return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,period_q,period_r,BufferVar2a,BufferVar2b)==0) return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,period_r,period_s,BufferVar2b,BufferVar3)==0) return 0;
         break;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferECCI[i]=(BufferVar3[i]!=0 ? (500.0*BufferVar2c[i])/BufferVar3[i] : 0);
   switch(InpMethod)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,period_s,trigger,BufferECCI,BufferTrigger);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,period_s,trigger,BufferECCI,BufferTrigger);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_s,trigger,BufferECCI,BufferTrigger,weight_sum7);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,period_s,trigger,BufferECCI,BufferTrigger);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
