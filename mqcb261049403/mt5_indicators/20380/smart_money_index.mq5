//+------------------------------------------------------------------+
//|                                            Smart_Money_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smart money index"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot SMI
#property indicator_label1  "SMI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uchar    InpOpenHour       =  3; // Open hour
input uchar    InpSessionLength  =  8; // Session length
//--- indicator buffers
double         BufferSMI[];
//--- global variables
int            open_hour;
int            session_length;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   open_hour=int(InpOpenHour>22 ? 22 : InpOpenHour);
   session_length=int(InpSessionLength>24 ? 24 : InpSessionLength<1 ? 1 : InpSessionLength);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSMI,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SMI");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSMI,true);
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
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSMI,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
         BufferSMI[i+1]=0;
      datetime t=time[i];
      t=t-open_hour*3600;
      t=(datetime)floor(t/86400+0.5)*86400;
      t=t+open_hour*3600;
      datetime from=(Period()<PERIOD_D1 ? t : TimeOpenDay(time[i],open_hour));
      datetime to=from+session_length*3600;
      int x1=BarShift(NULL,PERIOD_CURRENT,from);
      int x2=BarShift(NULL,PERIOD_CURRENT,to);
      if(x1>rates_total-1 || x2>rates_total-2 || x1==WRONG_VALUE || x2==WRONG_VALUE)
         continue;
      if(x1==i || x2==i)
        {
         int shift=(Period()<PERIOD_D1 ? 0 : 1);
         BufferSMI[i]=BufferSMI[i+1]-(close[x1+shift]-open[x1+shift])+(close[x2]-open[x2]);
        }
      else
         BufferSMI[i]=BufferSMI[i+1];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия дня                                    |
//+------------------------------------------------------------------+
datetime TimeOpenDay(const datetime time,const int hour_begin)
  {
   MqlDateTime tm;
   if(TimeToStruct(time,tm))
     {
      tm.hour=hour_begin;
      tm.min=0;
      return StructToTime(tm);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7004230         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(-1);
   return res;
  }
//+------------------------------------------------------------------+
