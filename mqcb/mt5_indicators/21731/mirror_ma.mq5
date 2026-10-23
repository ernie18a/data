//+------------------------------------------------------------------+
//|                                                    Mirror_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Mirror MA oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot MA1
#property indicator_label1  "Direct"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA2
#property indicator_label2  "Reverse"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Sig
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriod1        =  20;            // First MA period
input ENUM_MA_METHOD       InpMethod1        =  MODE_SMA;      // First MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;   // First MA applied price
input uint                 InpPeriod2        =  20;            // Second MA period
input ENUM_MA_METHOD       InpMethod2        =  MODE_SMA;      // Second MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_OPEN;    // Second MA applied price
input uint                 InpPeriodS        =  20;            // Signal period
input ENUM_MA_METHOD       InpMethodS        =  MODE_SMA;      // Signal method
//--- indicator buffers
double         BufferB1[];
double         BufferB2[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferSig[];
//--- global variables
int            period1;
int            period2;
int            periodS;
int            period_max;
int            weight_sum;
int            handle_ma1;
int            handle_ma2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   periodS=int(InpPeriodS<2 ? 2 : InpPeriodS);
   period_max=fmax(period1,fmax(period2,periodS));
   if(InpAppliedPrice2==InpAppliedPrice1 && period1==period2 && InpMethod1==InpMethod2)
     {
      Alert("The Applied price, Period and Method of the second MA can not be the same as the Applied price, Period and Method of the first MA.");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferB1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferB2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSig,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Mirror MA oscillator ("+(string)period1+","+(string)period2+","+(string)periodS+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer plot parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferSig,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period1,0,InpMethod1,InpAppliedPrice1);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period1,") by ",EnumToString(InpAppliedPrice1)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period2,0,InpMethod2,InpAppliedPrice2);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period2,") by ",EnumToString(InpAppliedPrice2)," object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferB1,0);
      ArrayInitialize(BufferB2,0);
      ArrayInitialize(BufferSig,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferB1[i]=BufferMA1[i]-BufferMA2[i];
      BufferB2[i]=BufferMA2[i]-BufferMA1[i];
     }
   switch(InpMethodS)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,periodS,BufferB1,BufferSig)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_max,periodS,BufferB1,BufferSig)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,periodS,BufferB1,BufferSig,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_max,periodS,BufferB1,BufferSig)==0) return 0;                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
