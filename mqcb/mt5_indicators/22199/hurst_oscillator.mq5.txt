//+------------------------------------------------------------------+
//|                                             Hurst_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Hurst oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot HO
#property indicator_label1  "Hurst Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  10;   // Period
input uint     InpPeriodSM =  1;    // Smoothing
//--- indicator buffers
double         BufferHO[];
double         BufferFlowValue[];
double         BufferCMA[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            period_sm;
int            displacement;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpPeriodSM<1 ? 1 : InpPeriodSM);
   displacement=int(period_ma/2.0+1.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFlowValue,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferCMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Hurst oscillator ("+(string)period_ma+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHO,true);
   ArraySetAsSeries(BufferFlowValue,true);
   ArraySetAsSeries(BufferCMA,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_MEDIAN);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(displacement+period_ma,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-displacement-period_ma-2;
      ArrayInitialize(BufferHO,EMPTY_VALUE);
      ArrayInitialize(BufferFlowValue,0);
      ArrayInitialize(BufferCMA,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCMA[i]=BufferMA[i+displacement];
      BufferFlowValue[i]=(close[i]>close[i+1] ? high[i] : close[i]<close[i+1] ? low[i] : (high[i]+low[i])/2.0);
      double MA=GetSMA(rates_total,i,period_sm,BufferFlowValue);
      BufferHO[i]=(MA-BufferCMA[i])/Point();
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
