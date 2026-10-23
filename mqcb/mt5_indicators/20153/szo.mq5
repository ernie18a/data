//+------------------------------------------------------------------+
//|                                                          SZO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Sentiment Zone Oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot SZO
#property indicator_label1  "SZO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodSZO   =  14;         // Period
input uint              InpPeriodDLev  =  30;         // Dynamic levels period
input double            InpPercentDLev =  95.0;       // Dynamic levels percent
input double            InpOverbought  =  7.0;        // Overbought
input double            InpOversold    = -7.0;        // Oversold
input ENUM_INPUT_YES_NO InpShowDLev    =  INPUT_YES;  // Show dynamic levels
//--- indicator buffers
double         BufferSZO[];
double         BufferTop[];
double         BufferBottom[];
double         BufferR[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferEMA3[];
//--- global variables
double         overbought;
double         oversold;
double         percent_dl;
int            period_dl;
int            period_szo;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_szo=int(InpPeriodSZO<1 ? 1 : InpPeriodSZO);
   period_dl=int(InpPeriodDLev<2 ? 2 : InpPeriodDLev);
   percent_dl=(InpPercentDLev<1 ? 100 : InpPercentDLev<50 ? 100-InpPercentDLev : InpPercentDLev);
   oversold=(InpOversold>0 ? 0 : InpOversold);
   overbought=(InpOverbought<0 ? 0 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSZO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferR,INDICATOR_DATA);
   SetIndexBuffer(4,BufferEMA1,INDICATOR_DATA);
   SetIndexBuffer(5,BufferEMA2,INDICATOR_DATA);
   SetIndexBuffer(6,BufferEMA3,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SZO("+(string)period_szo+","+(string)period_dl+","+DoubleToString(percent_dl,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSZO,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferR,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferEMA3,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period_szo*2) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit1=limit;
   int limit2=limit;
   if(limit>1)
     {
      limit=rates_total-2;
      limit1=limit-period_szo*3;
      limit2=limit-period_szo*3-period_dl;
      ArrayInitialize(BufferSZO,0);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferR,0);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferEMA3,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferR[i]=(close[i]>close[i+1]? 1 : -1);
//--- EMA1, EMA2, EMA3
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_szo,BufferR,BufferEMA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_szo,BufferEMA1,BufferEMA2);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_szo,BufferEMA2,BufferEMA3);

//--- Расчёт индикатора
   for(int i=limit1; i>=0 && !IsStopped(); i--)
      BufferSZO[i]=100.0*((3*BufferEMA1[i]-3*BufferEMA2[i]+BufferEMA3[i])/period_szo);

//--- Расчёт динамических уровней
   if(InpShowDLev)
     {
      for(int i=limit2; i>=0 && !IsStopped(); i--)
        {
         double hlp=BufferSZO[i];
         double llp=BufferSZO[i];
         for(int j=period_dl-1; j>=0; j--)
           {
            if(hlp<BufferSZO[i+j])
               hlp=BufferSZO[i+j];
            if(llp>BufferSZO[i+j])
               llp=BufferSZO[i+j];
           }
         double range=hlp-llp;
         double range_p=range*(percent_dl/100.0);
         BufferTop[i]=llp+range_p;
         BufferBottom[i]=hlp-range_p;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
