//+------------------------------------------------------------------+
//|                                                         TOSC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Difference between the recursive trendline value"
#property description "      and the exponential moving average"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot TOSC
#property indicator_label1  "TOSC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTOSC[];
double         BufferTMP0[];
double         BufferTMP1[];
double         BufferMA[];
double         BufferEMA[];
//--- global variables
double         alpha;
int            period;
int            handle_ma;
int            handle_ema;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   alpha=double(2.0/((double)period+1));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTOSC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTMP0,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTMP1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferEMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"TOSC("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTOSC,true);
   ArraySetAsSeries(BufferTMP0,true);
   ArraySetAsSeries(BufferTMP1,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ema=iMA(NULL,PERIOD_CURRENT,period,0,MODE_EMA,InpAppliedPrice);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTOSC,EMPTY_VALUE);
      ArrayInitialize(BufferTMP0,0);
      ArrayInitialize(BufferTMP1,0);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferEMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ema,0,0,count,BufferEMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferTMP0[i]=(1-alpha)*BufferTMP0[i+1]+BufferMA[i];
      BufferTMP1[i]=(1-alpha)*BufferTMP1[i+1]+alpha*(BufferMA[i]+BufferTMP0[i]-BufferTMP0[i+1]);
      BufferTOSC[i]=(BufferTMP1[i]-BufferEMA[i])/Point();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
