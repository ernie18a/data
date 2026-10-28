//+------------------------------------------------------------------+
//|                                            Anchored_Momentum.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Anchored Momentum oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot AMOM
#property indicator_label1  "AMomentum"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod1        =  2;             // First MA period
input ENUM_MA_METHOD       InpMethod1        =  2;             // First MA method
input uint                 InpPeriod2        =  42;            // Second MA period
input ENUM_MA_METHOD       InpMethod2        =  0;             // Second MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpBuffZoneUp     =  0.2;           // Upper limit of the buffered zone
input double               InpBuffZoneDn     = -0.2;           // Lower limit of the buffered zone
//--- indicator buffers
double         BufferAMOM[];
double         BufferColors[];
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
double         zone_up;
double         zone_dn;
int            period1;
int            period2;
int            period_max;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2==period1 ? period1+1 : InpPeriod2<1 ? 1 : InpPeriod2);
   period_max=fmax(period1,period2);
   zone_up=(InpBuffZoneUp<0 ? 0 : InpBuffZoneUp);
   zone_dn=(InpBuffZoneDn>0 ? 0 : InpBuffZoneDn);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAMOM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Anchored Momentum ("+(string)period1+","+(string)period2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,zone_up);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,zone_dn);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAMOM,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period1,0,InpMethod1,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period2,0,InpMethod2,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period2,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferAMOM,EMPTY_VALUE);
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
      double MA1=BufferMA1[i];
      double MA2=BufferMA2[i];

      BufferAMOM[i]=(MA2!=0 ? 100.0*(MA1/MA2-1.0) : 0);
      BufferColors[i]=(BufferAMOM[i]>BufferAMOM[i+1] ? 0 : BufferAMOM[i]<BufferAMOM[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
