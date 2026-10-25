//+------------------------------------------------------------------+
//|                                                     Forecast.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Forecast oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Forecast
#property indicator_label1  "Forecast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpPeriodSignal   =  3;             // Signal period
//--- indicator buffers
double         BufferFO[];
double         BufferSig[];
double         BufferMA[];
//--- global variables
int            period_fc;
int            period_sig;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fc=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sig=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSig,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Forecast Oscillator ("+(string)period_fc+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFO,true);
   ArraySetAsSeries(BufferSig,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_fc,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_fc-1;
      ArrayInitialize(BufferFO,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int t=period_fc;
      double sx=0;
      double sy=0;
      double sxy=0;
      double sx2=0;
      for(int j=i+period_fc;j>=i+1;j--)
        {
         sy+=BufferMA[j];
         sx+=t;
         sx2+=t*t;
         sxy+=BufferMA[j]*t;
         t--;
        }
      double b=(period_fc*sxy-sx*sy)/(period_fc*sx2-sx*sx);
      double a=(sy-b*sx)/period_fc;
      double tsf=a+b;

      BufferFO[i]=(BufferMA[i]!=0 ? 100.0*(BufferMA[i]-tsf)/BufferMA[i] : 0);
      BufferSig[i]=GetSMA(rates_total,i,period_sig,BufferFO);
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
