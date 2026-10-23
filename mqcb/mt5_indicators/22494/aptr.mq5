//+------------------------------------------------------------------+
//|                                                         APTR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average Percentage True Range indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot APTR
#property indicator_label1  "APTR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferAPTR[];
double         BufferPTR[];
//--- global variables
int            period_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAPTR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPTR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"APTR ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAPTR,true);
   ArraySetAsSeries(BufferPTR,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferAPTR,EMPTY_VALUE);
      ArrayInitialize(BufferPTR,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double s1=(high[i]+low[i]!=0     ? 2.0*(high[i]-low[i])/(high[i]+low[i])           : 0);
      double s2=(high[i]+close[i+1]!=0 ? 2.0*(high[i]-close[i+1])/(high[i]+close[i+1])   : 0);
      double s3=(low[i]-close[i+1]!=0  ? 2.0*(low[i]-close[i+1])/(3.0*low[i]-close[i+1]) : 0);
      BufferPTR[i]=fmax(s1,fmax(s2,s3));
      BufferAPTR[i]=100.0*GetSMA(rates_total,i,period_ma,BufferPTR);
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
