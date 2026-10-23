//+------------------------------------------------------------------+
//|                                                     ITrendMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Instantaneous Trendline by J.Ehlers"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ITMA
#property indicator_label1  "ITMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferITMA[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            handle_ma;
double         alpha;
double         c1,c2,c3,c4,c5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   alpha=2.0/double(period_ma+1);
   c1=alpha-alpha*alpha/4;
   c2=alpha*alpha/2;
   c3=alpha-0.75*alpha*alpha;
   c4=2*(1-alpha);
   c5=(1-alpha)*(1-alpha);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferITMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ITrendMA("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferITMA,true);
   ArraySetAsSeries(BufferMA,true);
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
   if(rates_total<period_ma) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferITMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i>rates_total-6)
         BufferITMA[i]=(BufferMA[i]+2*BufferMA[i+1]+BufferMA[i+2])/4;
      else
         BufferITMA[i]=c1*BufferMA[i]+c2*BufferMA[i+1]-c3*BufferMA[i+2]+c4*BufferITMA[i+1]-c5*BufferITMA[i+2];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
