//+------------------------------------------------------------------+
//|                                                          APR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average Period Range"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot APR
#property indicator_label1  "APR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_CALC_PRICE
  {
   PRICE_HL,            // High/Low
   PRICE_OC             // Open/Close
  };
enum ENUM_CALC_MODE
  {
   MODE_ABSOLUTE,       // Absolute
   MODE_RELATIVE        // Relative
  };
//--- input parameters
input ENUM_TIMEFRAMES   InpTimeframe   =  PERIOD_D1;     // Timeframe
input uint              InpPeriod      =  5;             // Period
input ENUM_CALC_PRICE   InpCalcPrice   =  PRICE_HL;      // Applied price
input ENUM_CALC_MODE    InpCalcMode    =  MODE_ABSOLUTE; // Calculation mode
//--- indicator buffers
double         BufferAPR[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAPR,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"APR("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAPR,true);
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
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferAPR,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int index=BarShift(Symbol(),InpTimeframe,time[i],false);
      if(index==WRONG_VALUE) return 0;
      double sum=0;
      for(int j=0; j<period; j++)
        {
         if(InpCalcPrice==PRICE_HL)
           {
            double h=High(InpTimeframe,index+j);
            double l=Low(InpTimeframe,index+j);
            if(h==0 || l==0) return 0;
            sum+=h-l;
           }
         else
           {
            double o=Open(InpTimeframe,index+j);
            double c=Close(InpTimeframe,index+j);
            if(o==0 || c==0) return 0;
            sum+=fabs(o-c);
           }
        }
      if(InpCalcMode==MODE_ABSOLUTE)
        {
         BufferAPR[i]=sum/period;
        }
      else
        {
         double opn=Open(InpTimeframe,index);
         if(opn==0) return 0;
         BufferAPR[i]=100*sum/(period*opn);
        }
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
//| Возвращает время указанного бара                                 |
//+------------------------------------------------------------------+
datetime Time(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   if(CopyTime(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
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
//| Возвращает High указанного бара                                  |
//+------------------------------------------------------------------+
double High(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает Low указанного бара                                   |
//+------------------------------------------------------------------+
double Low(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает Close указанного бара                                 |
//+------------------------------------------------------------------+
double Close(const ENUM_TIMEFRAMES timeframe,const int index)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyClose(Symbol(),timeframe,index,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
