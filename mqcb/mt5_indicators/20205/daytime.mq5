//+------------------------------------------------------------------+
//|                                                      DayTime.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Open
#property indicator_label3  "Open"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input ENUM_DAY_OF_WEEK  InpDay   =  MONDAY;  // Day of week
input uint              InpHour  =  12;      // Hour of day
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferOP[];
//--- global variables
int            hour;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   hour=int(InpHour>23 ? 23 : InpHour);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOP,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DayTime("+EnumToString(InpDay)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferOP,true);
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
   if(rates_total<3) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int day_of_week=TimeDayOfWeek(time[i]);
      int hour_of_day=TimeHour(time[i]);
      int prev_hour_of_day=TimeHour(time[i+1]);
      if(day_of_week==WRONG_VALUE || hour_of_day==WRONG_VALUE || prev_hour_of_day==WRONG_VALUE) return 0;
      if(day_of_week==InpDay && hour_of_day==hour && prev_hour_of_day!=InpHour)
        {
         int index=BarShift(PERIOD_D1,time[i]);
         double PrevDayOpen=Open(PERIOD_D1,index+1);
         datetime TimePrevDayOpen=Time(PERIOD_D1,index+1);
         int IndexPrevDayOpen=BarShift(PERIOD_CURRENT,TimePrevDayOpen);
         for(int j=IndexPrevDayOpen; j>=close[i+1]; j--)
            BufferOP[j]=PrevDayOpen;
         if(close[i+1]<PrevDayOpen){
            BufferUP[i]=low[i];
            }
         else if(close[i+1]>PrevDayOpen){
            BufferDN[i]=high[i];
            }
        }
      else
        {
         BufferDN[i]=BufferUP[i]=BufferOP[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает день недели указанной даты                            |
//+------------------------------------------------------------------+
int TimeDayOfWeek(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.day_of_week;
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
//| Возвращает смещение бара по времени                              |
//+------------------------------------------------------------------+
int BarShift(const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   int res=WRONG_VALUE;
   datetime last_bar=0;
   if(SeriesInfoInteger(Symbol(),timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      if(time>last_bar) res=0;
      else
        {
         const int shift=Bars(Symbol(),timeframe,time,last_bar);
         if(shift>0) res=shift-1;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Возвращает Open указанного бара                                  |
//+------------------------------------------------------------------+
double Open(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyOpen(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает Time указанного бара                                  |
//+------------------------------------------------------------------+
datetime Time(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   if(CopyTime(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
