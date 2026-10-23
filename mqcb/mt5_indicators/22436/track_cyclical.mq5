//+------------------------------------------------------------------+
//|                                               Track_Cyclical.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Track Cyclical oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot TC
#property indicator_label1  "Track Cyclical"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod            =  25;            // Period
input ENUM_MA_METHOD       InpMethod            =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_CLOSE;   // Applied price
input double               InpOverboughtExept   =  0.7;           // Exceptional overbought
input double               InpOverboughtAbnormal=  0.5;           // Abnormal overbought
input double               InpOverboughtNormal  =  0.3;           // Normal overbought
input double               InpOversoldNormal    = -0.3;           // Normal oversold
input double               InpOversoldAbnormal  = -0.5;           // Abnormal oversold
input double               InpOversoldExept     = -0.7;           // Exceptional oversold

//--- indicator buffers
double         BufferTC[];
double         BufferMA1[];
double         BufferMAP[];
//--- global variables
double         overbought_e;
double         overbought_a;
double         overbought_n;
double         oversold_n;
double         oversold_a;
double         oversold_e;
int            period;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought_n=(fabs(InpOverboughtNormal)<0.001 ? 0.001 : fabs(InpOverboughtNormal));
   overbought_a=(fabs(InpOverboughtAbnormal)<=overbought_n ? overbought_n+0.001 : fabs(InpOverboughtAbnormal));
   overbought_e=(fabs(InpOverboughtExept)<=overbought_a ? overbought_a+0.001 : fabs(InpOverboughtExept));
   oversold_n=(-fabs(InpOversoldNormal)>-0.001 ? -0.001 : -fabs(InpOversoldNormal));
   oversold_a=(-fabs(InpOversoldAbnormal)>=oversold_n ? oversold_n-0.001 : -fabs(InpOversoldAbnormal));
   oversold_e=(-fabs(InpOversoldExept)>=oversold_a ? oversold_a-0.001 : -fabs(InpOversoldExept));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Track Cyclical ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought_e);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overbought_a);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,overbought_n);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,oversold_n);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,oversold_a);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,5,oversold_e);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Exceptional overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Abnormal overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Normal overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,3,"Normal oversold");
   IndicatorSetString(INDICATOR_LEVELTEXT,4,"Abnormal oversold");
   IndicatorSetString(INDICATOR_LEVELTEXT,5,"Exceptional oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTC,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferTC,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTC[i]=(BufferMAP[i]!=0 ? 100.0*(BufferMA1[i]-BufferMAP[i])/BufferMAP[i] : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
