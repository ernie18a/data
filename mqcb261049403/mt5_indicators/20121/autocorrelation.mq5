//+------------------------------------------------------------------+
//|                                              Autocorrelation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot CRL
#property indicator_label1  "CRL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod=100;  // Period
//--- indicator buffers
double         BufferCRL[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCRL,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Autocorrelation("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCRL,true);
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
   int max=period*2;
   if(rates_total<max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=fmin(max,rates_total-max-1);
      ArrayInitialize(BufferCRL,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Подготовка данных
   double sko=0,sum=0,sumx=0,sumy=0,v1=0,v2=0;
   for(int j=0; j<=period; j++)
     {
      sko+=close[j]*close[j];
      sumx+=double(time[j]-time[period]);
      sumy+=close[j];
     }
   sko=sko/period;
   sumx/=(period+1);
   sumy/=(period+1);
   for(int j=0; j<period; j++)
     {
      v1+=(time[j]-time[period]-sumx)*(close[j]-sumy);
      v2+=(time[j]-time[period]-sumx)*(time[j]-time[period]-sumx);
     }
   v1/=v2;
   v2=sumy-v1*sumx;
   for(int j=0; j<=period; j++)
     {
      sum=0;
      for(int n=0; n<=period; n++)
        {
         if(j+n<=period)
            sum+=(close[n]-v1*(time[n]-time[period])-v2)*(close[n+j]-v1*(time[n+j]-time[period])-v2);
        }
      BufferCRL[j]=sum/sko;
     }
//--- Расчёт индикатора
   for(int i=period; i>=0 && !IsStopped(); i--)
     {
      BufferCRL[i]=BufferCRL[i]/BufferCRL[0];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
