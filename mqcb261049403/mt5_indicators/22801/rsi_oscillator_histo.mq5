//+------------------------------------------------------------------+
//|                                         RSI_Oscillator_Histo.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI Histogram Oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot OscRSI
#property indicator_label1  "Osc RSI"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLime,clrOrangeRed,clrGainsboro
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriodFastRSI  =  10;   // Fast RSI period
input uint     InpPeriodSlowRSI  =  25;   // Slow RSI period
input uint     InpPeriodMA       =  5;    // Smoothing
//--- indicator buffers
double         BufferOscRSI[];
double         BufferColors[];
double         BufferFRSI[];
double         BufferSRSI[];
double         BufferRAW[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_ma;
int            handle_frsi;
int            handle_srsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFastRSI<1 ? 1 : InpPeriodFastRSI);
   period_slow=int(InpPeriodSlowRSI==period_fast ? period_fast+1 : InpPeriodSlowRSI<1 ? 1 : InpPeriodSlowRSI);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOscRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferFRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Osc RSI ("+(string)period_fast+","+(string)period_slow+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOscRSI,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFRSI,true);
   ArraySetAsSeries(BufferSRSI,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create RSI's handles
   ResetLastError();
   handle_frsi=iRSI(NULL,PERIOD_CURRENT,period_fast,PRICE_CLOSE);
   if(handle_frsi==INVALID_HANDLE)
     {
      Print(__LINE__,": The iRSI(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_srsi=iRSI(NULL,PERIOD_CURRENT,period_slow,PRICE_CLOSE);
   if(handle_srsi==INVALID_HANDLE)
     {
      Print(__LINE__,": The iRSI(",(string)period_slow,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOscRSI,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferFRSI,0);
      ArrayInitialize(BufferSRSI,0);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_frsi,0,0,count,BufferFRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_srsi,0,0,count,BufferSRSI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=BufferFRSI[i]-BufferSRSI[i];
      BufferOscRSI[i]=GetSMA(rates_total,i,period_ma,BufferRAW);
      BufferColors[i]=(BufferOscRSI[i]>BufferOscRSI[i+1] ? 0 : BufferOscRSI[i]<BufferOscRSI[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
