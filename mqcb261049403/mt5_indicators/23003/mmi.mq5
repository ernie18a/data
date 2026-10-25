//+------------------------------------------------------------------+
//|                                                          MMI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Market Meanness Index indicator"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MMI
#property indicator_label1  "MMI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  200;  // Period
input double   InpOverbought  =  76.0; // Random boundings
input double   InpOversold    =  74.0; // Trend
//--- indicator buffers
double         BufferMMI[];
//--- global variables
int            period;
double         overbought;
double         oversold;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMMI,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Market Meanness Index ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Random");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Trend");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMMI,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferMMI,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int nl=0,nh=0;
      double mean=Mean(i,open,close);
      for(int j=i+1; j<=i+period; j++)
        {
         if(open[j]>close[j])
           {
            if(open[j]-close[j]>mean && open[j]-close[j]>open[j-1]-close[j-1]) nl++;
           }
         else
           {
            if(close[j]-open[j]<mean && close[j]-open[j]<close[j-1]-open[j-1]) nh++;
           }
        }
      BufferMMI[i]=100.0-100.0*(nl+nh)/(period-1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Mean(const int shift,const double &open[],const double &close[])
  {
   double sum=0;
   for(int i=shift; i<shift+period; i++)
      sum+=fabs(open[i]-close[i]);
   return(sum/period);
  }
//+------------------------------------------------------------------+
