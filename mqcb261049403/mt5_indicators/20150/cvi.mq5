//+------------------------------------------------------------------+
//|                                                          CVI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Chartmill Value Indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot CVI
#property indicator_label1  "CVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_MEDIAN;  // MA price
input ENUM_INPUT_YES_NO    InpModifiedAlg    =  INPUT_YES;     // Modified algorithm
input double               InpOverbought     =  0.5;           // Overbought
input double               InpOversold       = -0.5;           // Oversold
//--- indicator buffers
double         BufferCVI[];
double         BufferMA[];
double         BufferATR[];
//--- global variables
double         overbought;
double         oversold;
int            period;
int            handle_ma;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold>0 ? 0 : InpOversold);
   overbought=(InpOverbought<0 ? 0 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.01;
   if(oversold>=overbought) oversold=overbought-0.01;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCVI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CVI("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCVI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handle Stochastic
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period,") object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCVI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferCVI[i]=(close[i]-BufferMA[i])/(BufferATR[i]!=0 ? (InpModifiedAlg ? BufferATR[i]*sqrt(period) : BufferATR[i]) : DBL_MIN);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
