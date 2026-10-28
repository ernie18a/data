//+------------------------------------------------------------------+
//|                                                     SerialMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Point
#property indicator_label2  "Point"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BufferMA[];
double         BufferPoint[];
double         BufferTime[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPoint,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTime,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Serial MA");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPoint,true);
   ArraySetAsSeries(BufferTime,true);
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
   if(rates_total<3) return 0;
//--- Установка индексации массивов как у таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int total=rates_total-2,limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=total;
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferPoint,EMPTY_VALUE);
      ArrayInitialize(BufferTime,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==total)
         BufferTime[i]=(double)time[i];
      else
        {
         BufferTime[i]=BufferTime[i+1];
         int period_ma=BarShift(Symbol(),PERIOD_CURRENT,(datetime)BufferTime[i])-i+1;
         double summ=0;
         for(int n=0; n<period_ma; n++)
            summ+=close[i+n];
         if(period_ma!=0) BufferMA[i]=summ/period_ma;
         if((BufferMA[i]-close[i])*(BufferMA[i+1]-close[i+1])<0)
           {
            BufferTime[i]=(double)time[i];
            BufferPoint[i]=BufferMA[i]=close[i];
           }
         else
            BufferPoint[i]=EMPTY_VALUE;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//+------------------------------------------------------------------+
int BarShift(string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   if(symbol_name==NULL || symbol_name=="") symbol_name=Symbol();
   int res=WRONG_VALUE;
   datetime last_bar=0;
   if(::SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      if(time>last_bar) res=0;
      else
        {
         const int shift=::Bars(Symbol(),timeframe,time,last_bar);
         if(shift>0) res=shift-1;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
