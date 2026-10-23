//+------------------------------------------------------------------+
//|                                             Period_Open_Line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Line of period opening"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot POL
#property indicator_label1  "Period Open"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input ENUM_TIMEFRAMES   InpTimeframe=PERIOD_D1;  // Timeframe
//--- indicator buffers
double         BufferOPN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOPN,INDICATOR_DATA);
//--- settings indicators parameters
   string name="Period "+StringSubstr(EnumToString(InpTimeframe),7)+" Open";
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,name);
   PlotIndexSetString(0,PLOT_LABEL,name);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOPN,true);
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferOPN,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   int index=WRONG_VALUE;
   for(int i=limit; i>=0; i--)
     {
      index=(InpTimeframe<PERIOD_MN1 ? BarShift(Symbol(),InpTimeframe,time[i]) : BarShift(Symbol(),InpTimeframe,BeginOfYear(time[i])));
      if(index==WRONG_VALUE) return 0;
      BufferOPN[i]=Open(InpTimeframe,index);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/code/1864                                |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   datetime last_bar;
   if(!SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      datetime array[1];
      if(CopyTime(symbol_name,timeframe,0,1,array)==1)
         last_bar=array[0];
      else
         return WRONG_VALUE;
     }
   if(time>last_bar)
      return(0);
   int shift=Bars(symbol_name,timeframe,time,last_bar);
   datetime array[1];
   if(CopyTime(symbol_name,timeframe,time,1,array)==1)
      return(array[0]==time ? shift-1 : exact && time>array[0]+PeriodSeconds(timeframe) ? WRONG_VALUE : shift);
   return WRONG_VALUE;
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
//| Возвращает дату начала года указанной даты                       |
//+------------------------------------------------------------------+
datetime BeginOfYear(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   tm.mon=1;
   tm.day=1;
   return StructToTime(tm);
  }
//+------------------------------------------------------------------+
