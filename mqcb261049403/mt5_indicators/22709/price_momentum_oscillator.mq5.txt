//+------------------------------------------------------------------+
//|                                    Price_Momentum_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Price Momentum Oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot PMO
#property indicator_label1  "PMO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod1  =  35;   // Period one
input uint     InpPeriod2  =  20;   // Period two
input uint     InpPeriodSm =  10;   // Signal period
//--- indicator buffers
double         BufferPMO[];
double         BufferSignal[];
double         BufferRaw1[];
double         BufferRaw2[];
double         BufferSmoothing1[];
//--- global variables
double         smoothing1;
double         smoothing2;
int            periodS;
int            period1;
int            period2;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   periodS=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   smoothing1=2.0/period1;
   smoothing2=2.0/period2;
   period_max=(int)fmax(periodS,fmax(smoothing1,smoothing2));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPMO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRaw1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRaw2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSmoothing1,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Price Momentum Osc ("+(string)period1+","+(string)period2+","+(string)periodS+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPMO,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferRaw1,true);
   ArraySetAsSeries(BufferRaw2,true);
   ArraySetAsSeries(BufferSmoothing1,true);
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferPMO,0);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferRaw1,0);
      ArrayInitialize(BufferRaw2,0);
      ArrayInitialize(BufferSmoothing1,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRaw1[i]=(close[i+1]!=0 ? (((close[i]/close[i+1])*100.0)-100.0) : 0);
      BufferSmoothing1[i]=(BufferRaw1[i]-BufferSmoothing1[i+1])*smoothing1+BufferSmoothing1[i+1];
      BufferRaw2[i]=10.0*BufferSmoothing1[i];
      BufferPMO[i]=(BufferRaw2[i]-BufferPMO[i+1])*smoothing2+BufferPMO[i+1];
      BufferSignal[i]=ExponentialMA(rates_total,periodS,i,BufferPMO);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double ExponentialMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   static double prev_value=0;
   double result=0.0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
   double pr=2.0/(period+1.0);
//--- SMA for first data
   if(index==rates_total-period-1 || prev_value==0)
      prev_value=result=SimpleMA(rates_total,period,index,price);
//--- EMA
   else
     {
      result=prev_value+pr*(price[index]-prev_value);
      //--- new bar
      if(index!=0)
         prev_value=result;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SimpleMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
     result=result+price[index+i];
   result/=period;
//---
   return result;
  }
//+------------------------------------------------------------------+
