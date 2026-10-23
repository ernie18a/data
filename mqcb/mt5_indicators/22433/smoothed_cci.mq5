//+------------------------------------------------------------------+
//|                                                 Smoothed_CCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed CCI"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot SCCI
#property indicator_label1  "SCCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriodCCI         =  14;            // CCI period
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_TYPICAL; // Applied price
input ENUM_INPUT_YES_NO    InpUsePreSmoothing   =  INPUT_NO;      // Use pre-smoothing
input uint                 InpPeriodPre         =  14;            // Pre-smoothing period
input ENUM_MA_METHOD       InpMethodPre         =  MODE_SMA;      // Pre-smoothing method
input ENUM_INPUT_YES_NO    InpUsePostSmoothing  =  INPUT_NO;      // Use post-smoothing
input uint                 InpPeriodPost        =  14;            // Post-smoothing period
input ENUM_MA_METHOD       InpMethodPost        =  MODE_SMA;      // Post-smoothing method
input double               InpOverbought        =  100.0;         // Overbought
input double               InpOversold          = -100.0;         // Oversild
//--- indicator buffers
double         BufferSCCI[];
double         BufferSource[];
double         BufferRes[];
double         BufferSpTmpCCI[];
double         BufferDTmpCCI[];
double         BufferMTmpCCI[];
//--- global variables
double         overbought;
double         oversold;
int            period_pre;
int            period_cci;
int            period_post;
int            period_max;
int            handle_ma1;
int            handle_maP;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<2 ? 2 : InpPeriodCCI);
   period_pre=int(InpPeriodPre<2 ? 2 : InpPeriodPre);
   period_post=int(InpPeriodPost<2 ? 2 : InpPeriodPost);
   period_max=fmax(period_cci,fmax(period_pre,period_post));
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : InpOverbought>100.0 ? 100.0 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold)<-100.0 ? -100.0 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSCCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSource,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRes,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSpTmpCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDTmpCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMTmpCCI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed CCI ("+(string)period_cci+","+(string)period_pre+","+(string)period_post+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSCCI,true);
   ArraySetAsSeries(BufferSource,true);
   ArraySetAsSeries(BufferRes,true);
   ArraySetAsSeries(BufferSpTmpCCI,true);
   ArraySetAsSeries(BufferDTmpCCI,true);
   ArraySetAsSeries(BufferMTmpCCI,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_pre,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_pre,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferSCCI,EMPTY_VALUE);
      ArrayInitialize(BufferSource,0);
      ArrayInitialize(BufferRes,0);
      ArrayInitialize(BufferSpTmpCCI,0);
      ArrayInitialize(BufferDTmpCCI,0);
      ArrayInitialize(BufferMTmpCCI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   if(!InpUsePreSmoothing)
      copied=CopyBuffer(handle_ma1,0,0,count,BufferSource);
   else
      copied=CopyBuffer(handle_maP,0,0,count,BufferSource);
   if(copied!=count) return 0;

//--- CCIOnArray
   int begin=(InpUsePreSmoothing ? period_pre : 0);
   if(CCIOnArray(rates_total,prev_calculated,begin,period_cci,BufferSource,BufferSpTmpCCI,BufferDTmpCCI,BufferMTmpCCI,BufferRes)==0)
      return 0;
//--- Расчёт индикатора
   if(!InpUsePostSmoothing)
     {
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferSCCI[i]=BufferRes[i];
     }
   else
     {
      begin=(InpUsePreSmoothing ? period_cci : 0);
      switch(InpMethodPost)
        {
         case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,begin,period_post,BufferRes,BufferSCCI)==0) return 0;               break;
         case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,begin,period_post,BufferRes,BufferSCCI)==0) return 0;                  break;
         case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,begin,period_post,BufferRes,BufferSCCI,weight_sum)==0) return 0; break;
         //---MODE_SMA
         default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,begin,period_post,BufferRes,BufferSCCI)==0) return 0;                    break;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Commodity Channel Index on array                                 |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
template<typename T>
int CCIOnArray(const int rates_total,
               const int prev_calculated,
               const int begin,
               const int period,
               const T &price[],
               double &buffer_sp[],
               double &buffer_d[],
               double &buffer_m[],
               double &buffer_cci[]
              )
  {
//--- variables
   int    i,j;
   double dTmp,dMul=0.015/period;
//--- start calculation
   int StartCalcPosition=(period-1)+begin;
//--- check for bars count
   if(period<2 || rates_total<StartCalcPosition)
      return(0);
      
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_cci=ArrayGetAsSeries(buffer_cci);
   if(as_series_price)
      ArraySetAsSeries(price,false);
   if(as_series_cci)
     {
      ArraySetAsSeries(buffer_cci,false);
      ArraySetAsSeries(buffer_sp,false);
      ArraySetAsSeries(buffer_d,false);
      ArraySetAsSeries(buffer_m,false);
     }
//--- calculate position
   int pos=prev_calculated-1;
   if(pos<StartCalcPosition)
      pos=StartCalcPosition;
//--- main cycle
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
      //--- SMA on price buffer
      buffer_sp[i]=SimpleMA(i,period,price);
      //--- calculate D
      dTmp=0.0;
      for(j=0;j<period;j++)
         dTmp+=fabs(price[i-j]-buffer_sp[i]);
      buffer_d[i]=dTmp*dMul;
      //--- calculate M
      buffer_m[i]=price[i]-buffer_sp[i];
      //--- calculate CCI
      if(buffer_d[i]!=0.0) 
         buffer_cci[i]=buffer_m[i]/buffer_d[i];
      else
         buffer_cci[i]=0.0;
     }
//--- restore as_series flags
   if(as_series_price) ArraySetAsSeries(price,true);
   if(as_series_cci)
     {
      ArraySetAsSeries(buffer_cci,true);
      ArraySetAsSeries(buffer_sp,true);
      ArraySetAsSeries(buffer_d,true);
      ArraySetAsSeries(buffer_m,true);
     }
//---- CCIOnArray done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
