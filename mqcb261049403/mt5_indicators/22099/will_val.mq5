//+------------------------------------------------------------------+
//|                                                     WILL_VAL.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Larry Williams' WILL VAL oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot WV
#property indicator_label1  "WV"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSlateBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string   InpInstrument  =  "EURJPY";   // Instrument
input uint     InpPeriod1     =  22;         // First EMA period
input uint     InpPeriod2     =  2;          // Second EMA period
input uint     InpPeriod3     =  365;        // Period
input double   InpOverbought  =  75.0;       // Overbought
input double   InpOversold    =  25.0;       // Oversold
//--- indicator buffers
double         BufferWV[];
double         BufferPrice[];
double         BufferValue[];
double         BufferAvgPrice1[];
double         BufferAvgPrice2[];
//--- global variables
double         overbought;
double         oversold;
int            period_1;
int            period_2;
int            period_3;
int            period_max;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- enable timer
   EventSetTimer(90);
//--- set global variables
   if(!SymbolCheck(InpInstrument))
      return INIT_FAILED;
   if(InpInstrument==Symbol())
     {
      Print("Error. The Instrument must not be the same as the current symbol.");
      return INIT_FAILED;
     }
   period_1=int(InpPeriod1<2 ? 2 : InpPeriod1);
   period_2=int(InpPeriod2==period_1 ? period_1+1 : InpPeriod2<2 ? 2 : InpPeriod2);
   period_3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   period_max=fmax(period_1,fmax(period_2,period_3));
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWV,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferAvgPrice1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgPrice2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferValue,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WILL VAL ("+InpInstrument+","+(string)period_1+","+(string)period_2+","+(string)period_3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"WV("+InpInstrument+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWV,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferAvgPrice1,true);
   ArraySetAsSeries(BufferAvgPrice2,true);
   ArraySetAsSeries(BufferValue,true);
//---
   Time(InpInstrument,0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(InpInstrument,0);
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
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferWV,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferAvgPrice1,0);
      ArrayInitialize(BufferAvgPrice2,0);
      ArrayInitialize(BufferValue,0);
     }

//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int j=BarShift(InpInstrument,PERIOD_CURRENT,time[i]);
      if(j==WRONG_VALUE)
         continue;
      double price=Close(InpInstrument,j);
      BufferPrice[i]=close[i]/(price!=WRONG_VALUE ? price : 1.0);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_1,BufferPrice,BufferAvgPrice1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_2,BufferPrice,BufferAvgPrice2)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferValue[i]=BufferAvgPrice1[i]-BufferAvgPrice2[i];

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferValue,i,period_3);
      int bh=ArrayMaximum(BufferValue,i,period_3);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferValue[bl];
      double max=BufferValue[bh];
      BufferWV[i]=(max!=min ? 100.0*(BufferValue[i]-min)/(max-min) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
