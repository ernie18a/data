//+------------------------------------------------------------------+
//|                                                        TMACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Triangular Moving Average Convergence/Divergence oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot TMACD
#property indicator_label1  "TMACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodFast     =  7;             // Fast TriMA period
input uint                 InpPeriodSlow     =  14;            // Slow TriMA period
input uint                 InpPeriodSig      =  5;             // Signal period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTMACD[];
double         BufferColors[];
double         BufferSignal[];
double         BufferFMA[];
double         BufferSMA[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sig;
int            period_f;
int            period_s;
int            period_max;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_sma=int(InpPeriodSlow==period_fma ? period_fma+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
   period_f=(int)floor(period_fma/2)+1;
   period_s=(int)floor(period_sma/2)+1;
   period_max=fmax(period_f,period_s);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TMACD ("+(string)period_fma+","+(string)period_sma+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTMACD,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_f,0,MODE_SMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_f,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_s,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_s,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferTMACD,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTMACD[i]=(GetSMA(rates_total,i,period_f,BufferFMA)-GetSMA(rates_total,i,period_s,BufferSMA));
      BufferSignal[i]=GetSMA(rates_total,i,period_sig,BufferTMACD);
      BufferColors[i]=(BufferTMACD[i]>BufferTMACD[i+1] ? 0 : BufferTMACD[i]<BufferTMACD[i+1] ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
