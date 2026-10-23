//+------------------------------------------------------------------+
//|                                                   JSmooth_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "JSmooth Moving Average"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot JSMA
#property indicator_label1  "JSMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrChocolate
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferJSMA[];
double         BufferMA[];
double         BufferA1[];
double         BufferA2[];
double         BufferA3[];
double         BufferA4[];
//--- global variables
double         alpha;
double         alpha2;
double         alpha12;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
   alpha=0.45*(double(period-1))/(0.45*(period-1)+2);
   alpha2=alpha*alpha;
   alpha12=(1-alpha)*(1-alpha);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferJSMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferA4,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"JSMA("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferJSMA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferA1,true);
   ArraySetAsSeries(BufferA2,true);
   ArraySetAsSeries(BufferA3,true);
   ArraySetAsSeries(BufferA4,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferJSMA,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferA1,0);
      ArrayInitialize(BufferA2,0);
      ArrayInitialize(BufferA3,0);
      ArrayInitialize(BufferA4,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferA1[i]=(1-alpha)*BufferMA[i]+alpha*BufferA1[i+1];
      BufferA2[i]=(1-alpha)*(BufferMA[i]-BufferA1[i])+alpha*BufferA2[i+1];
      BufferA3[i]=BufferA1[i]+BufferA2[i];
      BufferA4[i]=(BufferA3[i]-BufferJSMA[i+1])*alpha12+alpha2*BufferA4[i+1];
      BufferJSMA[i]=BufferJSMA[i+1]+BufferA4[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
