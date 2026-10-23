//+------------------------------------------------------------------+
//|                                                    RSI_STARC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI + STARC indicators"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
//--- plot RSI
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Top
#property indicator_label3  "Top"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpPeriodRSI   =  14;   // RSI period
input uint     InpPeriodATR   =  10;   // ATR period
input uint     InpPeriodMA    =  14;   // Smoothing
input double   InpMultiplierT =  2.0;  // Top line multiplier
input double   InpMultiplierB =  2.0;  // Bottom line multiplier
//--- indicator buffers
double         BufferRSI[];
double         BufferCenter[];
double         BufferTop[];
double         BufferBottom[];
double         BufferTR[];
//--- global variables
int            period_rsi;
int            period_atr;
int            smoothing;
int            handle_rsi;
int            handle_maP;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   smoothing=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCenter,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(4,BufferTR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI STARC ("+(string)period_rsi+","+(string)period_atr+","+(string)smoothing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferCenter,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferTR,true);
//--- create MA's handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferCenter,EMPTY_VALUE);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferTR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,smoothing,BufferRSI,BufferCenter);   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTR[i]=fabs(BufferRSI[i]-BufferRSI[i+1]);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double atr=SMAOnArray(BufferTR,0,period_atr,0,i);
      BufferTop[i]=BufferCenter[i]+InpMultiplierT*atr;
      BufferBottom[i]=BufferCenter[i]-InpMultiplierB*atr;
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
   return(buf[0]);
  }
//+------------------------------------------------------------------+
