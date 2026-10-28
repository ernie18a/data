//+------------------------------------------------------------------+
//|                                               Stochastic_ROC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic ROC"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot SROC
#property indicator_label1  "SROC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_MODE_LINE
  {
   LINE_MAIN   =  MAIN_LINE,  // Main
   LINE_SIGNAL =  SIGNAL_LINE // Signal
  };
//---
enum ENUM_CALC_TYPE
  {
   CALC_TYPE_ABS,    // Absolute
   CALC_TYPE_RLTV    // Relative
  };
//--- input parameters
input uint           InpPeriodK     =  8;             // Stochastic K period
input uint           InpPeriodD     =  3;             // Stochastic D period
input uint           InpSlowing     =  3;             // Stochastic Slowing
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;      // Stochastic MA Method
input ENUM_STO_PRICE InpPriceField  =  STO_LOWHIGH;   // Stochastic Price field
input ENUM_MODE_LINE InpLineMode    =  LINE_MAIN;     // Stochastic line
input uint           InpPeriodROC   =  1;             // ROC period
input ENUM_CALC_TYPE InpCalcType    =  CALC_TYPE_ABS; // Calculation type
//--- indicator buffers
double         BufferSROC[];
double         BufferSTO[];
//--- global variables
int   period_k;
int   period_d;
int   slowing;
int   period_r;
int   handle_sto;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   period_r=int(InpPeriodROC<1 ? 1 : InpPeriodROC);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSROC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSTO,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"StochasticROC("+(string)period_k+","+(string)period_d+","+(string)slowing+","+(string)period_r+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSROC,true);
   ArraySetAsSeries(BufferSTO,true);
//--- create MA's handle
   ResetLastError();
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,slowing,InpMethod,InpPriceField);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k,",",(string)period_d,","+(string)slowing,",",(string)period_r,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_r-1;
      ArrayInitialize(BufferSROC,EMPTY_VALUE);
      ArrayInitialize(BufferSTO,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_sto,InpLineMode,0,count,BufferSTO);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferSROC[i]=
        (
         InpCalcType==CALC_TYPE_ABS ? BufferSTO[i]-BufferSTO[i+period_r] : 
         ((BufferSTO[i]-BufferSTO[i+period_r])/(BufferSTO[i+period_r]!=0 ? BufferSTO[i+period_r] : 1.0))*100.0
        );

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
