//+------------------------------------------------------------------+
//|                                                  Trend_Force.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend force oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot TF
#property indicator_label1  "TForce"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrOrange,clrRed,clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod      =  12;   // Period
input uint     InpPeriodATR   =  7;    // ATR's period
input double   InpCoeffATR    =  2.0;  // ATR's coefficient
//--- indicator buffers
double         BufferTF[];
double         BufferColors[];
double         BufferMin[];
double         BufferMax[];
double         BufferATR[];
//--- global variables
double         coeff;
int            period;
int            period_atr;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   coeff=InpCoeffATR;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TForce("+(string)period+","+(string)period_atr+","+DoubleToString(coeff,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTF,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMin,true);
   ArraySetAsSeries(BufferMax,true);
   ArraySetAsSeries(BufferATR,true);
//--- create MA's handle
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   if(rates_total<period || Point()==0) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTF,EMPTY_VALUE);
      ArrayInitialize(BufferMin,0);
      ArrayInitialize(BufferMax,0);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=Highest(period_atr,i);
      int bl=Lowest(period_atr,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE) continue;
      BufferMin[i]=high[bh]-coeff*BufferATR[i];
      BufferMax[i]=low[bl]+coeff*BufferATR[i];
     }
//--- Расчёт индикатора
   double Up=0,Dn=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=ArrayMaximum(BufferMin,i,period);
      int bl=ArrayMinimum(BufferMax,i,period);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE) continue;
      Up=BufferMin[bh];
      Dn=BufferMax[bl];
      BufferTF[i]=(Up-Dn)/Point();
      if(BufferTF[i]>0)
         BufferColors[i]=(BufferTF[i]>BufferTF[i+1] ? 0 : 1);
      else
         BufferColors[i]=(BufferTF[i]<BufferTF[i+1] ? 2 : 3);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
