//+------------------------------------------------------------------+
//|                                                       ZScore.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ZScore
#property indicator_label1  "ZScore"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period of calculation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferZScore[];
double         BufferDev[];
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
int            period;
int            handle_dev;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferZScore,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA2,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"ZScore("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferZScore,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- creating handles StdDev, MA1, MA2
   handle_dev=iStdDev(Symbol(),PERIOD_CURRENT,period,0,MODE_SMA,InpAppliedPrice);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("Error creating StdDev's handle: ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("Error creating MA(1)'s handle: ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(Symbol(),PERIOD_CURRENT,period,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("Error creating MA(",(string)period,")'s handle: ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferZScore,EMPTY_VALUE);
      ArrayInitialize(BufferDev,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,EMPTY_VALUE);
      ArrayInitialize(BufferMA2,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=(limit>1 ? rates_total : 1);
   int copied_dev=CopyBuffer(handle_dev,0,0,copied,BufferDev);
   if(copied_dev!=copied)
      return 0;
   int copied_ma1=CopyBuffer(handle_ma1,0,0,copied,BufferMA1);
   if(copied_ma1!=copied)
      return 0;
   int copied_ma2=CopyBuffer(handle_ma2,0,0,copied,BufferMA2);
   if(copied_ma2!=copied)
      return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double dev=BufferDev[i];
      BufferZScore[i]=(BufferMA1[i]-BufferMA2[i])/(dev>0 ? dev : DBL_MIN);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
