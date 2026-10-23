//+------------------------------------------------------------------+
//|                                    Simple_Support_Resistance.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Simple Support/Resistance indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Resistance
#property indicator_label1  "Resistance"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Support
#property indicator_label2  "Support"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint     InpPeriod      =  15;   // Period
input uint     InpBarsBefore  =  50;   // Lines length
//--- indicator buffers
double         BufferRes[];
double         BufferSup[];
//--- global variables
int            period;
int            bars_before;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   bars_before=int(InpBarsBefore<2 ? 2 : InpBarsBefore);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRes,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSup,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Support/Resistance("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRes,true);
   ArraySetAsSeries(BufferSup,true);
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
   if(rates_total<period || rates_total<bars_before) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRes,EMPTY_VALUE);
      ArrayInitialize(BufferSup,EMPTY_VALUE);
     }
//--- Подготовка данных
   int bl=Lowest(period,1);
   int bh=Highest(period,1);
   if(bl==WRONG_VALUE || bh==WRONG_VALUE) return 0;
   double min=low[bl];
   double max=high[bh];
   double Sup=2*min-max;
   double Res=2*max-min;
//--- Расчёт индикатора
   for(int i=0; i<bars_before && !IsStopped(); i++)
     {
      BufferRes[i]=Res;
      BufferSup[i]=Sup;
     }
   BufferRes[bars_before]=EMPTY_VALUE;
   BufferSup[bars_before]=EMPTY_VALUE;
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
