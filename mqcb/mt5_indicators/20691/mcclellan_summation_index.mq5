//+------------------------------------------------------------------+
//|                                    McClellan_Summation_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "McClellan summation index"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MOIDX
#property indicator_label1  "Summation IDX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- defines
#define   RESERVE          (100)
//--- input parameters
input string   InpBaseCurrency   =  "USD";   // Base currency
input uint     InpPeriodFast     =  19;      // Fast MA period
input uint     InpPeriodSlow     =  39;      // Slow MA period
//--- indicator buffers
double         BufferMOIDX[];
double         BufferRANA[];
double         BufferFMA[];
double         BufferSMA[];
////--- global variables
string         base_symbol;
int            num_symbols;
int            period_fast;
int            period_slow;
//--- structures
struct SSymbol
  {
   string      name;
   bool        inverse;
   int         bars;
   void        Refresh(void) { datetime array[]; ::CopyTime(name,PERIOD_CURRENT,0,1,array); }
  }            array_symbols[];
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set timer
   EventSetTimer(90);
//--- set global variables
   base_symbol=InpBaseCurrency;
   period_fast=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   StringTrimLeft(base_symbol);
   StringTrimRight(base_symbol);
   num_symbols=InitSymbols(InpBaseCurrency);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMOIDX,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRANA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"McClellan summation index "+base_symbol+"("+(string)num_symbols+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMOIDX,true);
   ArraySetAsSeries(BufferRANA,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
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
   int min_bars=4;
   if(rates_total<min_bars || !CheckBars(rates_total,min_bars)) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMOIDX,0);
      ArrayInitialize(BufferRANA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferFMA,0);
     }
   int limit_min=fmin(rates_total,MinBars(rates_total))-1;
//--- Подготовка данных
   int total=(limit==0 ? limit : limit_min);
   for(int i=total; i>=0 && !IsStopped(); i--)
     {
      double Up=0,Dn=0;
      for(int j=0; j<num_symbols; j++)
        {
         string symbol=array_symbols[j].name;
         int index=BarShift(symbol,PERIOD_CURRENT,time[i],true);
         if(index==WRONG_VALUE)
            continue;
         double C=Close(symbol,index);
         double O=Open(symbol,index);
         if(array_symbols[j].inverse)
           {
            if(C>O) Dn++;
            if(C<O) Up++;
           }
         else
           {
            if(C>O) Up++;
            if(C<O) Dn++;
           }
        }
      BufferRANA[i]=(Up+Dn!=0 ? (Up-Dn)/(Up+Dn) : 0);
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_fast,BufferRANA,BufferFMA);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_slow,BufferRANA,BufferSMA);
//--- Расчёт индикатора
   for(int i=total; i>=0 && !IsStopped(); i--)
      BufferMOIDX[i]=BufferMOIDX[i+1]+(BufferFMA[i]-BufferSMA[i]);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int total=num_symbols;
   if(total==0)
      return;
   for(int i=0;i<total;i++)
      array_symbols[i].Refresh();
  }
//+------------------------------------------------------------------+
//| Инициализирует коллекцию инструментов                            |
//+------------------------------------------------------------------+
int InitSymbols(const string base)
  {
   string array[];
   int n=0,total=SymbolsTotal(true);
   ArrayResize(array,total,RESERVE);
   for(int i=0; i<total; i++)
     {
      string symbol=SymbolName(i,true);
      if(StringFind(symbol,base)==WRONG_VALUE)
         continue;
      n++;
      ArrayResize(array,n,RESERVE);
      array[n-1]=symbol;
     }
   n=0;
   total=ArraySize(array);
   ArrayResize(array_symbols,total,RESERVE);
   for(int i=0; i<total; i++)
     {
      string symbol=array[i];
      int pos=StringFind(symbol,base);
      if(pos==WRONG_VALUE)
         continue;
      n++;
      array_symbols[n-1].name=symbol;
      array_symbols[n-1].inverse=(pos>0 ? true : false);
      array_symbols[n-1].bars=Bars(symbol,PERIOD_CURRENT);
     }
   return n;
  }
//+------------------------------------------------------------------+
//| Проверка количества баров                                        |
//+------------------------------------------------------------------+
bool CheckBars(const int rates_total,int min_bars)
  {
   bool res=true;
   int total=ArraySize(array_symbols);
   for(int i=0; i<total; i++)
     {
      string symbol=array_symbols[i].name;
      array_symbols[i].bars=(symbol==Symbol() ? rates_total : Bars(symbol,PERIOD_CURRENT));
      array_symbols[i].Refresh();
      if(array_symbols[i].bars<min_bars)
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает наименьшее количество bars                            |
//+------------------------------------------------------------------+
int MinBars(const int rates_total)
  {
   int total=ArraySize(array_symbols),min_bars=rates_total;
   for(int i=0; i<total; i++)
     {
      if(array_symbols[i].bars<min_bars)
         min_bars=array_symbols[i].bars;
     }
   return min_bars;
  }
//+------------------------------------------------------------------+
//| Возвращает Open                                                  |
//+------------------------------------------------------------------+
double Open(const string symbol_name,const int shift)
  {
   double array[];
   if(CopyOpen(symbol_name,PERIOD_CURRENT,shift,1,array)==1)
      return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   if(CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1)
      return array[0];
   return 0;
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
