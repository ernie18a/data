//+------------------------------------------------------------------+
//|                                               On_Screen_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "On screen MACD indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Zero
#property indicator_label4  "Zero"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_width4  1
//--- input parameters
input uint                 InpPeriodFast     =  12;            // Fast EMA period
input uint                 InpPeriodSlow     =  26;            // Slow EMA period
input uint                 InpPeriodSig      =  9;             // Signal period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSignal[];
double         BufferHist[];
double         BufferZero[];
double         BufferRAW[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_sig;
int            period_max;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferZero,INDICATOR_DATA);
   SetIndexBuffer(4,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"On screen MACD ("+(string)period_fast+","+(string)period_slow+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferZero,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_EMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_EMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_sig,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sig-1;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferZero,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferMACD);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferZero);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=BufferMACD[i]-BufferZero[i];
      BufferSignal[i]=BufferZero[i]+GetSMA(rates_total,i,period_sig,BufferRAW);
      BufferHist[i]=BufferZero[i]+BufferMACD[i]-BufferSignal[i];
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
