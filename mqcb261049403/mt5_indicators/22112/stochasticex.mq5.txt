//+------------------------------------------------------------------+
//|                                                 StochasticEx.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic expansion indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot K
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodK     =  13;   // %K period
input uint     InpSlowing     =  6;    // Slowing
input uint     InpNoiseFilter =  6;    // Noise filter period
//--- indicator buffers
double         BufferK[];
double         BufferSignal[];
double         BufferHigh[];
double         BufferLow[];
//--- global variables
int            period_k;
int            slowing;
int            noise;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   noise=int(InpNoiseFilter<2 ? 2 : InpNoiseFilter);
   period_max=fmax(noise,fmax(slowing,period_k));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLow,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic expansion ("+(string)period_k+","+(string)slowing+","+(string)noise+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_k-1;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferHigh,0);
      ArrayInitialize(BufferLow,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period_k,i);
      int bh=Highest(period_k,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      BufferLow[i]=close[i]-min;
      BufferHigh[i]=max-close[i];
      
      double Avg_Low=GetSMA(rates_total,i,slowing,BufferLow);
      double Avg_High=GetSMA(rates_total,i,slowing,BufferHigh);
      double KB1=(Avg_High!=0 ? Avg_Low/Avg_High : 0);
      double KB2=(Avg_Low!=0 ? -Avg_High/Avg_Low : 0);
      BufferK[i]=KB1+KB2;
      BufferSignal[i]=GetSMA(rates_total,i,noise,BufferK);
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
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
