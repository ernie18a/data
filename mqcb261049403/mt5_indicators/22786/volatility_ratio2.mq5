//+------------------------------------------------------------------+
//|                                            Volatility_Ratio2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility Ratio2 oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot VR
#property indicator_label1  "VR2"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepPink
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  14;         // Period
input double            InpThreshold   =  2.0;        // Threshold
input ENUM_INPUT_YES_NO InpUseAlert    =  INPUT_YES;  // Show alerts
//--- indicator buffers
double         BufferVR[];
double         BufferTR[];
double         BufferEMATR[];
//--- global variables
double         threshold;
int            period_vr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_vr=int(InpPeriod<1 ? 1 : InpPeriod);
   threshold=InpThreshold;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferEMATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility Ratio2 ("+(string)period_vr+","+(string)threshold+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Threshold");
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVR,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferEMATR,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVR,EMPTY_VALUE);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferEMATR,0);
     }

//--- Расчёт индикатора
   static datetime last_alert=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTR[i]=fmax(fmax(high[i]-low[i],fabs(high[i]-close[i+1])),fabs(close[i+1]-low[i]));
      BufferEMATR[i]=EMA(rates_total,BufferTR[i],BufferEMATR[i+1],period_vr,i);
      BufferVR[i]=(BufferEMATR[i]!=0 ? BufferTR[i]/BufferEMATR[i] : 0);
      //--- alerts
      if(InpUseAlert && i==0 && time[0]>last_alert && BufferVR[0]>threshold)
        {
         Alert(Symbol()+","+TimeframeToString(Period())+": Volatility Ratio > "+(string)threshold+")");
         last_alert=TimeCurrent();
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| EMA                                                              |
//+------------------------------------------------------------------+
double EMA(const int rates_total,const double price,const double prev_value,const int period,const int shift)
  {
   return (shift<rates_total-2 ? prev_value+2.0/(1+period)*(price-prev_value) : price);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
