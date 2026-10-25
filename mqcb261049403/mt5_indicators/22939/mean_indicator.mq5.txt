//+------------------------------------------------------------------+
//|                                               Mean_Indicator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Mean Indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Mean
#property indicator_label1  "Mean"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP
#property indicator_label2  "Up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "Down"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpDayStart =  0;    // Day hour begin
//--- indicator buffers
double         BufferMean[];
double         BufferUP[];
double         BufferDN[];
double         BufferTemp[];
//--- global variables
int            begin;
int            bars_current;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   begin=(int)InpDayStart;
   bars_current=BarsCurrentInTimeframe(PERIOD_D1);
   if(Period()>PERIOD_H1)
     {
      Alert("This indicator works only on H1 charts and lower");
      ChartSetSymbolPeriod(0,NULL,PERIOD_H1);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMean,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTemp,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Mean Indicator ("+(string)begin+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMean,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTemp,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(bars_current,4) || !IsTimeframeDataReady(PERIOD_D1)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMean,EMPTY_VALUE);
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferTemp,0);
     }

//--- Расчёт индикатора
   double daily_mean=0;
   int prev_start=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDN[i]=BufferUP[i]=BufferMean[i]=EMPTY_VALUE;
      if(TimeHour(time[i])==begin)
        {
         int day_bar=BarShift(NULL,PERIOD_D1,time[i]);
         if(day_bar==WRONG_VALUE)
            continue;
         datetime day_time=Time(NULL,PERIOD_D1,day_bar+1);
         if(day_time==0)
            continue;
         prev_start=BarShift(NULL,PERIOD_CURRENT,day_time);
         if(prev_start==WRONG_VALUE)
            continue;
         //---
         int n=0;
         daily_mean=0;
         for(int j=prev_start; j>i; j--)
           {
            if(j>rates_total-1)
               continue;
            daily_mean+=close[j];
            n++;
           }
         daily_mean=(daily_mean/n);
         prev_start=i;
        }
      BufferMean[i]=BufferTemp[i]=daily_mean;

      if(i<prev_start)
        {
         int n=0;
         double current_mean=0;
         for(int j=prev_start; j>i; j--)
           {
            current_mean+=close[j];
            n++;
           }
         BufferTemp[i]=current_mean/n;
        }
      if(BufferTemp[i]>=BufferTemp[i+1])
         BufferUP[i]=BufferTemp[i];
      else
         BufferDN[i]=BufferTemp[i];
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает количество минут в периоде                            |
//+------------------------------------------------------------------+
int MinutesInPeriod(ENUM_TIMEFRAMES timeframe)
  {
   if(timeframe==PERIOD_CURRENT) timeframe=Period();
   return PeriodSeconds(timeframe)/60;
  }  
//+------------------------------------------------------------------+
//| Возвращает количество баров в периоде                            |
//+------------------------------------------------------------------+
int BarsCurrentInTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return MinutesInPeriod(timeframe)/MinutesInPeriod(PERIOD_CURRENT);
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
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Проверка наличия исторических данных по таймфрейму               |
//| https://www.mql5.com/ru/forum/280448#comment_8762312             |
//+------------------------------------------------------------------+
bool IsTimeframeDataReady(ENUM_TIMEFRAMES timeframe)
  {
   ResetLastError();
   iTime(NULL,timeframe,1);
   return GetLastError()==ERR_SUCCESS;
  }
//+------------------------------------------------------------------+
