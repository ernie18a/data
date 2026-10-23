//+------------------------------------------------------------------+
//|                                                     MedianMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MedianMA
#property indicator_label1  "MedianMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot TMP
#property indicator_label2  "TMP"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMedianMA[];
double         BufferMA[];
//--- global variables
double         TMP[];
int            handle_ma;
int            period;
int            index;
bool           even;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   if(ArrayResize(TMP,period)==WRONG_VALUE)
     {
      Print("Failed to set the size of the TMP array");
      return INIT_FAILED;
     }
   even=(round(period/2)*2==period ? true : false);
   index=(int)floor(period/2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMedianMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Median Moving Average("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMedianMA,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1-period;
      ArrayInitialize(BufferMedianMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit==0 ? 1 : rates_total);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      for(int n=0; n<period; n++)
         TMP[n]=BufferMA[i+n];
      ArraySort(TMP);
      if(even)
         BufferMedianMA[i]=(TMP[index]+TMP[index-1])/2;
      else
         BufferMedianMA[i]=TMP[index];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
