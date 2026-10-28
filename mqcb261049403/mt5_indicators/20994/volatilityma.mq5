//+------------------------------------------------------------------+
//|                                                 VolatilityMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility moving average"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot VolMA
#property indicator_label1  "VolMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpLookBack       =  300;           // Period
input double               InpBarrier        =  2.0;           // Barrier
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferVolMA[];
double         BufferMA[];
double         BufferRAW[];
double         BufferRawAVG[];
double         BufferLength[];
//--- global variables
double         barrier;
int            lookback;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   barrier=(InpBarrier<0 ? 0 : InpBarrier);
   lookback=int(InpLookBack<1 ? 1 : InpLookBack);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVolMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRawAVG,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLength,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility moving average ("+(string)lookback+","+DoubleToString(barrier,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVolMA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferRawAVG,true);
   ArraySetAsSeries(BufferLength,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<lookback) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-lookback-2;
      ArrayInitialize(BufferVolMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferRawAVG,0);
      ArrayInitialize(BufferLength,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW[i]=(BufferMA[i]-BufferMA[i+1])/(BufferMA[i]!=0 ? BufferMA[i] : 1.0);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,lookback,BufferRAW,BufferRawAVG);
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double var=0;
      for(int j=0; j<=lookback; j++)
         var+=pow(BufferRAW[i+j]+BufferRawAVG[i],2);
      double sDev=sqrt(var/lookback);
      double sDevNow=BufferRAW[i]/(BufferMA[i]*sDev);
      BufferLength[i]=(fabs(sDevNow)>barrier ? 1 : BufferLength[i+1]+1);
      BufferVolMA[i]=SMAOnArray(BufferMA,0,(int)BufferLength[i],0,i);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double SMAOnArray(double &array[],int total,int period,int ma_shift,int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
//---
   total=ArrayCopy(arr,array,0,shift+ma_shift,period);
   if(ArrayResize(buf,total)<0) return(0);
   double sum=0;
   int    i,pos=total-1;
   for(i=1;i<period;i++,pos--)
      sum+=arr[pos];
   while(pos>=0)
     {
      sum+=arr[pos];
      buf[pos]=sum/period;
      sum-=arr[pos+period-1];
      pos--;
     }
   return buf[0];
  }
//+------------------------------------------------------------------+
