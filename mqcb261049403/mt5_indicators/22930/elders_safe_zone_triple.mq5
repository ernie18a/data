//+------------------------------------------------------------------+
//|                                      Elders_Safe_Zone_Triple.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Elder's Triple Safe Zone indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot ESZ1
#property indicator_label1  "ESZ One"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ESZ2
#property indicator_label2  "ESZ Two"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ESZ3
#property indicator_label3  "ESZ Three"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod1     =  10;   // First ESZ Period
input uint     InpStopFactor1 =  3;    // First Stop factor
input uint     InpPeriodEMA1  =  13;   // First EMA period
//---
input uint     InpPeriod2     =  20;   // Second ESZ Period
input uint     InpStopFactor2 =  6;    // Second Stop factor
input uint     InpPeriodEMA2  =  50;   // Second EMA period
//---
input uint     InpPeriod3     =  30;   // Third ESZ Period
input uint     InpStopFactor3 =  10;   // Third Stop factor
input uint     InpPeriodEMA3  =  100;  // Third EMA period
//--- indicator buffers
double         BufferESZ1[];
double         BufferESZ2[];
double         BufferESZ3[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferEMA3[];
//--- global variables
int            period_esz1;
int            period_esz2;
int            period_esz3;
int            period_ema1;
int            period_ema2;
int            period_ema3;
int            stop_factor1;
int            stop_factor2;
int            stop_factor3;
int            period_max;
int            handle_ma1;
int            handle_ma2;
int            handle_ma3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_esz1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_esz2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_esz3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   period_ema1=int(InpPeriodEMA1<1 ? 1 : InpPeriodEMA1);
   period_ema2=int(InpPeriodEMA2<1 ? 1 : InpPeriodEMA2);
   period_ema3=int(InpPeriodEMA3<1 ? 1 : InpPeriodEMA3);
   stop_factor1=int(InpStopFactor1<1 ? 1 : InpStopFactor1);
   stop_factor2=int(InpStopFactor2<1 ? 1 : InpStopFactor2);
   stop_factor3=int(InpStopFactor3<1 ? 1 : InpStopFactor3);
   period_max=fmax(period_esz1,fmax(period_esz2,period_esz3));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferESZ1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferESZ2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferESZ3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferEMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferEMA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Elder's Triple Safe Zone");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferESZ1,true);
   ArraySetAsSeries(BufferESZ2,true);
   ArraySetAsSeries(BufferESZ3,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferEMA3,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_ema1,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_ema2,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma3=iMA(NULL,PERIOD_CURRENT,period_ema3,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma3==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema3,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-3;
      ArrayInitialize(BufferESZ1,EMPTY_VALUE);
      ArrayInitialize(BufferESZ2,EMPTY_VALUE);
      ArrayInitialize(BufferESZ3,EMPTY_VALUE);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferEMA3,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferEMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferEMA2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma3,0,0,count,BufferEMA3);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      CalculateESZ(i,period_esz1,stop_factor1,BufferESZ1,BufferEMA1,high,low,close);
      CalculateESZ(i,period_esz2,stop_factor2,BufferESZ2,BufferEMA2,high,low,close);
      CalculateESZ(i,period_esz3,stop_factor3,BufferESZ3,BufferEMA3,high,low,close);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateESZ(const int shift,const int period,const int factor,double &esz[],const double &ema[],const double &high[],const double &low[],const double &close[])
  {
   double PreSafeStop=esz[shift+1];
   double Pen=0;
   double Counter=0;
   double SafeStop=0;

   if(ema[shift]>ema[shift+1])
     {
      for(int j=0; j<period; j++)
        {
         if(low[shift+j]<low[shift+j+1])
           {
            Pen=low[shift+j+1]-low[shift+j]+Pen;
            Counter++;
           }
        }

      if(Counter>0)
         SafeStop=close[shift]-(factor*(Pen/Counter));
      else
         SafeStop=close[shift]-(factor*Pen);
      if(SafeStop<PreSafeStop && ema[shift+1]>ema[shift+2])
         SafeStop=PreSafeStop;
     }
   else if(ema[shift]<ema[shift+1])
     {
      for(int j=0; j<period; j++)
        {
         if(high[shift+j]>high[shift+j+1])
           {
            Pen=high[shift+j]-high[shift+j+1]+Pen;
            Counter++;
           }
        }

      if(Counter>0)
         SafeStop=close[shift]+(factor*(Pen/Counter));
      else
         SafeStop=close[shift]+(factor*Pen);
      if(SafeStop>PreSafeStop && ema[shift+1]<ema[shift+2])
         SafeStop=PreSafeStop;
     }
   PreSafeStop=SafeStop;
   esz[shift]=SafeStop;
  }  
//+------------------------------------------------------------------+
