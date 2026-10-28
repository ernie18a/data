//+------------------------------------------------------------------+
//|                                                          TII.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Intensity Index indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot TII
#property indicator_label1  "TII"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  30;            // Period
input uint                 InpPeriodMA       =  60;            // MA Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferTII[];
double         BufferMA1[];
double         BufferMAP[];
double         BufferUP[];
double         BufferDN[];
double         BufferPos[];
double         BufferNeg[];
//--- global variables
int            period_tii;
int            period_ma;
int            handle_ma1;
int            handle_maP;
double         overbought;
double         oversold;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tii=int(InpPeriod<2 ? 2 : InpPeriod);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTII,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferNeg,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Intensity Index ("+(string)period_tii+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTII,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferPos,true);
   ArraySetAsSeries(BufferNeg,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTII,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Pr=BufferMA1[i];
      double MA=BufferMAP[i];
      if(Pr>MA)
        {
         BufferUP[i]=Pr-MA;
         BufferDN[i]=0;
        }
      else
        {
         if(Pr<MA)
           {
            BufferUP[i]=0;
            BufferDN[i]=MA-Pr;
           }
         else
           {
            BufferUP[i]=0;
            BufferDN[i]=0;
           }
        }
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ma,period_tii,BufferUP,BufferPos)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ma,period_tii,BufferDN,BufferNeg)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double pos=BufferPos[i];
      double neg=BufferNeg[i];
      BufferTII[i]=(pos+neg!=0 ? 100.0*pos/(pos+neg) : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
