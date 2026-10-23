//+------------------------------------------------------------------+
//|                                             DiffMA_Histogram.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "The difference between two SMA by range of candle directionaly"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot DMA
#property indicator_label1  "DMA"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDMA[];
double         BufferColors[];
double         BufferMA[];
//--- global variables
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Diff MA ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDMA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double SumUp=0;
      double SumDn=0;
      int CountUp=0;
      int CountDn=0;
      int j=i;
      while(j<=rates_total-2 && (CountUp<period || CountDn<period))
        {
         if(close[j]>open[j] && CountUp<period)
           {
            CountUp++;
            SumUp+=BufferMA[j];
           }
         else
           {
            if(close[j]<open[j] && CountDn<period)
              {
               CountDn++;
               SumDn+=BufferMA[j];
              }
           }
         j++;
        }

      if(CountUp>0 && CountDn>0)
        {
         double MA_Up=SumUp/CountUp;
         double MA_Dn=SumDn/CountDn;
         BufferDMA[i]=MA_Up-MA_Dn;
         BufferColors[i]=(BufferDMA[i]>BufferDMA[i+1] ? 0 : BufferDMA[i]<BufferDMA[i+1] ? 1 : 2);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
