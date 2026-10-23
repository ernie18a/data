//+------------------------------------------------------------------+
//|                                                      HLBands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Band Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Band Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSlateBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label day Upper
#property indicator_label3  "Open"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLightSteelBlue
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- enums
enum ENUM_CALC_METHOD
  {
   PRICE_HL,            // High/Low
   PRICE_OC             // Open/Close
  };
enum ENUM_MODE_UPDATE
  {
   MODE_UPDATE_OPEN,    // at the opening of the bar
   MODE_UPDATE_ALWAYS   // always
  };
//--- input parameters
input ENUM_TIMEFRAMES   InpTimeframe      =  PERIOD_D1;        // Bands period
input ENUM_MODE_UPDATE  InpBandUpdate     =  MODE_UPDATE_OPEN; // Bands Update
input ENUM_CALC_METHOD  InpBandCalcMethod =  PRICE_HL;         // Bands Applied price
//--- indicator buffers
double         BufferH[];
double         BufferL[];
double         BufferOpen[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferH,INDICATOR_DATA);
   SetIndexBuffer(1,BufferL,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOpen,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,220);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,true);
//--- settings indicators parameters
   string tfn=StringSubstr(EnumToString(InpTimeframe),7);
   IndicatorSetString(INDICATOR_SHORTNAME,"High/Low Bands("+tfn+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferL,true);
   ArraySetAsSeries(BufferOpen,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   static int index_curr=WRONG_VALUE;
   static int index_prev=WRONG_VALUE;
   static datetime tm=0;
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      index_curr=(InpTimeframe<PERIOD_MN1 ? BarShift(Symbol(),InpTimeframe,time[limit]) : BarShift(Symbol(),InpTimeframe,BeginOfYear(time[limit])));
      if(index_curr==WRONG_VALUE) return 0;
      ArrayInitialize(BufferH,EMPTY_VALUE);
      ArrayInitialize(BufferL,EMPTY_VALUE);
      ArrayInitialize(BufferOpen,EMPTY_VALUE);
      BufferH[limit]=(InpBandCalcMethod==PRICE_HL ? high[limit] : fmax(open[limit],close[limit]));
      BufferL[limit]=(InpBandCalcMethod==PRICE_HL ? low[limit]  : fmin(open[limit],close[limit]));
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      index_curr=(InpTimeframe<PERIOD_MN1 ? BarShift(Symbol(),InpTimeframe,time[i]) : BarShift(Symbol(),InpTimeframe,BeginOfYear(time[i])));
      if(index_curr==WRONG_VALUE) return 0;
      static datetime time_bar=0;
      double H=UpperPrice(InpTimeframe,index_curr);
      double L=LowerPrice(InpTimeframe,index_curr);
      //---
      if(index_curr!=index_prev)
        {
         if(index_prev>index_curr)
           {
            time_bar=time[i];
            BufferH[i]=(InpBandUpdate==MODE_UPDATE_OPEN ? (InpBandCalcMethod==PRICE_HL ? high[i] : fmax(open[i],close[i])) : H);
            BufferL[i]=(InpBandUpdate==MODE_UPDATE_OPEN ? (InpBandCalcMethod==PRICE_HL ? low[i]  : fmin(open[i],close[i])) : L);
            BufferOpen[i]=open[i];
           }
         index_prev=index_curr;
        }
      //---
      int bar=BarShift(Symbol(),PERIOD_CURRENT,time_bar);
      if(bar==WRONG_VALUE) continue;
      if(bar==0)
        {
         BufferH[i]=(InpBandCalcMethod==PRICE_HL ? high[i] : fmax(open[i],close[i]));
         BufferL[i]=(InpBandCalcMethod==PRICE_HL ? low[i]  : fmin(open[i],close[i]));
         BufferOpen[i]=open[i];
        }
      else
        {
         BufferH[i]=BufferH[bar];
         BufferL[i]=BufferL[bar];
         BufferOpen[i]=BufferOpen[bar];
         if(InpBandUpdate==MODE_UPDATE_ALWAYS)
           {
            double highest=(InpBandCalcMethod==PRICE_HL ? H : HighestPrice(i,bar,open,close));
            double lowhest=(InpBandCalcMethod==PRICE_HL ? L : LowestPrice(i,bar,open,close));
            SetPrice(highest,i,bar,BufferH);
            SetPrice(lowhest,i,bar,BufferL);
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает наибольшую цену цепочки баров                         |
//+------------------------------------------------------------------+
double HighestPrice(const int start,const int end,const double &open[],const double &close[])
  {
   double array[];
   ArraySetAsSeries(array,true);
   int total=(end-start)+1;
   ArrayResize(array,total,20);
   for(int i=0; i<total; i++)
      array[i]=fmax(open[start+i],close[start+i]);
   return array[ArrayMaximum(array)];
  }
//+------------------------------------------------------------------+
//| Возвращает наименьшую цену цепочки баров                         |
//+------------------------------------------------------------------+
double LowestPrice(const int start,const int end,const double &open[],const double &close[])
  {
   double array[];
   ArraySetAsSeries(array,true);
   int total=(end-start)+1;
   ArrayResize(array,total,20);
   for(int i=0; i<total; i++)
      array[i]=fmin(open[start+i],close[start+i]);
   return array[ArrayMinimum(array)];
  }
//+------------------------------------------------------------------+
//| Устанавливает цену цепочке баров                                 |
//+------------------------------------------------------------------+
void SetPrice(const double price,const int start,const int end,double &buffer[])
  {
   for(int i=start; i<=end; i++)
      buffer[i]=price;
  }
//+------------------------------------------------------------------+
//| Возвращает верхнюю цену бара                                     |
//+------------------------------------------------------------------+
double UpperPrice(ENUM_TIMEFRAMES timeframe,const int index)
  {
   return
   (
    InpBandCalcMethod==PRICE_HL ? High(timeframe,index) :
    (Open(timeframe,index)==0 || Close(timeframe,index)==0 ? 0 : fmax(Open(timeframe,index),Close(timeframe,index)))
    );
  }
//+------------------------------------------------------------------+
//| Возвращает нижнюю цену бара                                      |
//+------------------------------------------------------------------+
double LowerPrice(ENUM_TIMEFRAMES timeframe,const int index)
  {
   return
   (
    InpBandCalcMethod==PRICE_HL ? Low(timeframe,index) :
    (Open(timeframe,index)==0 || Close(timeframe,index)==0 ? 0 : fmin(Open(timeframe,index),Close(timeframe,index)))
    );
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
//| Возвращает номер дня месяца                                      |
//+------------------------------------------------------------------+
int TimeDay(const datetime time)
  {
   MqlDateTime tm;
   int day_number=WRONG_VALUE;
   if(TimeToStruct(time,tm))
      day_number=tm.day;
   return day_number;
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
//| ВОзвращает наименование таймфрейма                               |
//+------------------------------------------------------------------+
string NameTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
