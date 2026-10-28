//+------------------------------------------------------------------+
//|                                               WVF_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William’s VIX Fix Stochastic"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot K
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodWVF   =  14;      // WVF period
input uint     InpPeriodK     =  5;       // %K period
input uint     InpPeriodD     =  3;       // %D period
input double   InpOverbought  =  80.0;    // Overbought
input double   InpOversold    =  20.0;    // Oversold
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferWVF[];
//--- global variables
double         overbought;
double         oversold;
int            period_wvf;
int            period_k;
int            period_d;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_wvf=int(InpPeriodWVF<1 ? 1 : InpPeriodWVF);
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   period_max=fmax(period_wvf,fmax(period_k,period_d));
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferWVF,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WVF Stochastic ("+(string)period_wvf+","+(string)period_k+","+(string)period_d+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//IndicatorSetDouble(INDICATOR_MINIMUM,0);
//IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferWVF,true);
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
   if(rates_total<fmax(period_max,4))
      return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferK,EMPTY_VALUE);
      ArrayInitialize(BufferD,EMPTY_VALUE);
      ArrayInitialize(BufferWVF,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=HighestClose(period_wvf,i);
      if(bh==WRONG_VALUE)
         continue;
      double max=close[bh];
      BufferWVF[i]=(max>0 ? 100*(max-low[i])/max : 0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferWVF,i,period_k);
      int bh=ArrayMaximum(BufferWVF,i,period_k);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      
      double minLow=BufferWVF[bl];
      double maxHigh=BufferWVF[bh];
      double mins=BufferWVF[i]-minLow;
      double maxes=maxHigh-minLow;
      BufferK[i]=(maxes>0 ? 100.0*mins/maxes : 50.0);
      BufferD[i]=GetSMA(rates_total,i,period_d,BufferK);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Close         |
//+------------------------------------------------------------------+
int HighestClose(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
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
