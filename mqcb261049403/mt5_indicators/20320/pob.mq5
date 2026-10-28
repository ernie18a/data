//+------------------------------------------------------------------+
//|                                                          POB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Point of Balance"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot BL
#property indicator_label1  "BL (Up)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot POB
#property indicator_label2  "POB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BR
#property indicator_label3  "BR (Down)"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferBL[];
double         BufferPOB[];
double         BufferBR[];
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
   SetIndexBuffer(0,BufferBL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPOB,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBR,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"POB("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBL,true);
   ArraySetAsSeries(BufferPOB,true);
   ArraySetAsSeries(BufferBR,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferBL,EMPTY_VALUE);
      ArrayInitialize(BufferPOB,EMPTY_VALUE);
      ArrayInitialize(BufferBR,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int highest_h=Highest(NULL,PERIOD_CURRENT,PRICE_HIGH,period,i);
      int highest_l=Highest(NULL,PERIOD_CURRENT,PRICE_LOW,period,i);
      int lowest_h=Lowest(NULL,PERIOD_CURRENT,PRICE_HIGH,period,i);
      int lowest_l=Lowest(NULL,PERIOD_CURRENT,PRICE_LOW,period,i);
      if(highest_h==WRONG_VALUE || highest_l==WRONG_VALUE || lowest_h==WRONG_VALUE || lowest_l==WRONG_VALUE)
         return 0;
      double MinH=high[lowest_h];
      double MaxH=high[highest_h];
      double MinL=low[lowest_l];
      double MaxL=low[highest_l];
      BufferBL[i]=(MinH+MaxH)/2;
      BufferBR[i]=(MinL+MaxL)/2;
      BufferPOB[i]=(BufferBL[i]+BufferBR[i])/2;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии               |
//+------------------------------------------------------------------+
int Highest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      default:
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии                |
//+------------------------------------------------------------------+
int Lowest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      default:
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
