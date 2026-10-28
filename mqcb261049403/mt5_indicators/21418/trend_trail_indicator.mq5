//+------------------------------------------------------------------+
//|                                        Trend_Trail_Indicator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Trail indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Trend
#property indicator_label1  "Stop line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodATR   =  10;   // ATR period
input double   InpMultiplier  =  2.8;  // Multiplier
//--- indicator buffers
double         BufferTrend[];
double         BufferHL[];
double         BufferDiff[];
double         BufferSupport[];
double         BufferWMA[];
//--- global variables
int            period_atr;
double         multiplier;
double         k;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   multiplier=InpMultiplier;
   k=1.0/period_atr;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTrend,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHL,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDiff,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSupport,INDICATOR_DATA);
   SetIndexBuffer(4,BufferWMA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Trail ("+(string)period_atr+","+DoubleToString(multiplier,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferHL,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferSupport,true);
   ArraySetAsSeries(BufferWMA,true);
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
   if(rates_total<fmax(period_atr,5)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      ArrayInitialize(BufferTrend,EMPTY_VALUE);
      ArrayInitialize(BufferHL,0);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferSupport,0);
      ArrayInitialize(BufferWMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHL[i]=high[i]-low[i];
      double Avg_HL=GetSMA(rates_total,i,period_atr,BufferHL);
      double HiLo=fmin(BufferHL[i],1.5*Avg_HL);
      double Href=(low[i]>high[i+1] ? high[i]-close[i+1]-(low[i]-high[i+1])/2.0 : high[i]-close[i+1]);
      double Lref=(high[i]<low[i+1] ? close[i+1]-low[i]-(low[i+1]-high[i])/2.0  : close[i+1]-low[i]);
      double diff1=fmax(HiLo,Href);
      BufferDiff[i]=fmax(diff1,Lref);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferWMA[i]=GetSMA(rates_total,i,period_atr,BufferDiff);
         BufferSupport[i]=close[i];
         BufferTrend[i]=close[i];
         continue;
        }
      BufferWMA[i]=(BufferDiff[i]-BufferWMA[i+1])*k+BufferWMA[i+1];

      double loss=multiplier*BufferWMA[i];
      double resistance=close[i]+loss;

      BufferSupport[i]=
        (
         low[i]>=low[i+2] && low[i+1]>=low[i+2] && low[i+3]>=low[i+2] && low[i+4]>=low[i+2] ? low[i+2] :
         low[i]>high[i+1]*1.0013 ? high[i+1]*0.9945 :
         low[i]>BufferSupport[i+1]*1.1 ? BufferSupport[i+1]*1.05 :
         BufferSupport[i+1]
        );
      BufferTrend[i]=
        (
         high[i]>BufferTrend[i+1] && high[i+1]>BufferTrend[i+1] ? fmax(BufferTrend[i+1],BufferSupport[i]) :
         high[i]<BufferTrend[i+1] && high[i+1]<BufferTrend[i+1] ? fmin(BufferTrend[i+1],resistance) :
         high[i]>BufferTrend[i+1] ? BufferSupport[i] :
         resistance
        );
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
