//+------------------------------------------------------------------+
//|                                                          VLM.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Voltest (VLM) indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot VLM
#property indicator_label1  "VLM"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrRed,clrLime,clrGreen,clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  30;   // Period
//--- indicator buffers
double         BufferVLM[];
double         BufferColors[];
double         BufferVol[];
//--- global variables
int            period_sm;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVLM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VLM ("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVLM,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferVol,true);
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
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_sm,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVLM,EMPTY_VALUE);
      ArrayInitialize(BufferVol,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=(double)tick_volume[i];

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double VolAvg=GetSMA(rates_total,i,period_sm,BufferVol);
      BufferVLM[i]=(VolAvg!=0 ? BufferVol[i]/(VolAvg*Point()) : 0);

      int h=TimeHour(time[i]);
      if(h==WRONG_VALUE)
         continue;
      
      BufferColors[i]=
        (
         h>=8  && h<14  ? 0 :
         h>=14 && h<18  ? 1 :
         h>=18 && h<=21 ? 0 :
         h>=22          ? 2 : 3
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
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.hour;
  }
//+------------------------------------------------------------------+
