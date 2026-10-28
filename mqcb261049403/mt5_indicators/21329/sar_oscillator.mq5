//+------------------------------------------------------------------+
//|                                               SAR_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "SAR Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot SARH
#property indicator_label1  "SARH"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input double   InpStepSAR  =  0.02; // SAR step
input double   InpMaxSAR   =  0.2;  // SAR maximum
input uint     InpPeriod   =  7;    // Smoothing Period
//--- indicator buffers
double         BufferSARH[];
double         BufferColors[];
double         BufferSAR[];
double         BufferRAW[];
//--- global variables
double         step;
double         max;
int            period_ma;
int            handle_sar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   step=(InpStepSAR<0.0001 ? 0.0001 : InpStepSAR);
   max=(InpMaxSAR<0.0001 ? 0.0001 : InpMaxSAR);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSARH,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSAR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SAR Oscillator "+DoubleToString(step,2)+","+DoubleToString(max,2)+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSARH,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSAR,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create SAR handles
   ResetLastError();
   handle_sar=iSAR(NULL,PERIOD_CURRENT,step,max);
   if(handle_sar==INVALID_HANDLE)
     {
      Print("The iSAR(",DoubleToString(step,2),","+DoubleToString(max,2),") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSARH,EMPTY_VALUE);
      ArrayInitialize(BufferSAR,0);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sar,0,0,count,BufferSAR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=close[i]-BufferSAR[i];
      BufferSARH[i]=GetSMA(rates_total,i,period_ma,BufferRAW);
      BufferColors[i]=(BufferSARH[i]>BufferSARH[i+1] ? 0 : BufferSARH[i]<BufferSARH[i+1] ? 1 : 2);
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
