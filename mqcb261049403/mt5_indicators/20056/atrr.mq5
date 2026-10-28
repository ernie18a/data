//+------------------------------------------------------------------+
//|                                                         ATRR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot ATRR
#property indicator_label1  "ATRR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodATR1=10; // ATR1 Period
input uint     InpPeriodATR2=20; // ATR2 Period
//--- indicator buffers
double         BufferATRR[];
double         BufferATR1[];
double         BufferATR2[];
//--- global variables
int            period_atr1;
int            period_atr2;
int            handle_atr1;
int            handle_atr2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr1=int(InpPeriodATR1<1 ? 1 : InpPeriodATR1);
   period_atr2=int(InpPeriodATR2<1 ? 1 : InpPeriodATR2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferATRR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferATR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferATR2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ATRR("+(string)period_atr1+","+(string)period_atr2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferATR1,true);
   ArraySetAsSeries(BufferATR2,true);
   ArraySetAsSeries(BufferATRR,true);
//--- create handle ATR1, ATR2
   ResetLastError();
   handle_atr1=iATR(NULL,PERIOD_CURRENT,period_atr1);
   if(handle_atr1==INVALID_HANDLE)
     {
      Print("The first iATR(",(string)period_atr1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_atr2=iATR(NULL,PERIOD_CURRENT,period_atr2);
   if(handle_atr2==INVALID_HANDLE)
     {
      Print("The second iATR(",(string)period_atr2,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferATR1,EMPTY_VALUE);
      ArrayInitialize(BufferATR2,EMPTY_VALUE);
      ArrayInitialize(BufferATRR,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_atr1,0,0,count,BufferATR1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr2,0,0,count,BufferATR2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double one=BufferATR1[i];
      double two=BufferATR2[i];
      BufferATRR[i]=(one/(two>0 ? two : DBL_MIN))*100.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
