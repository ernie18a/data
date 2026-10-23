//+------------------------------------------------------------------+
//|                                             Elders_Safe_Zone.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Elder's Safe Zone indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ESZ
#property indicator_label1  "ESZ"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod      =  10;   // ESZ Period
input uint     InpStopFactor  =  3;    // Stop factor
input uint     InpPeriodEMA   =  13;   // EMA period
//--- indicator buffers
double         BufferESZ[];
double         BufferEMA[];
//--- global variables
int            period_esz;
int            period_ema;
int            stop_factor;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_esz=int(InpPeriod<1 ? 1 : InpPeriod);
   period_ema=int(InpPeriodEMA<1 ? 1 : InpPeriodEMA);
   stop_factor=int(InpStopFactor<1 ? 1 : InpStopFactor);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferESZ,INDICATOR_DATA);
   SetIndexBuffer(1,BufferEMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Elder's Safe Zone ("+(string)period_esz+","+(string)stop_factor+","+(string)period_ema+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferESZ,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ema,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_esz,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_esz-3;
      ArrayInitialize(BufferESZ,EMPTY_VALUE);
      ArrayInitialize(BufferEMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferEMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double PreSafeStop=BufferESZ[i+1];
      double Pen=0;
      double Counter=0;
      double SafeStop=0;
      if(BufferEMA[i]>BufferEMA[i+1])
        {
         for(int j=0; j<period_esz; j++)
           {
            if(low[i+j]<low[i+j+1])
              {
               Pen=low[i+j+1]-low[i+j]+Pen;
               Counter++;
              }
           }
         if(Counter>0)
            SafeStop=close[i]-(stop_factor*(Pen/Counter));
         else
            SafeStop=close[i]-(stop_factor*Pen);
         if(SafeStop<PreSafeStop && BufferEMA[i+1]>BufferEMA[i+2])
            SafeStop=PreSafeStop;
        }
      else if(BufferEMA[i]<BufferEMA[i+1])
        {
         for(int j=0; j<period_esz; j++)
           {
            if(high[i+j]>high[i+j+1])
              {
               Pen=high[i+j]-high[i+j+1]+Pen;
               Counter++;
              }
           }
         if(Counter>0)
            SafeStop=close[i]+(stop_factor*(Pen/Counter));
         else
            SafeStop=close[i]+(stop_factor*Pen);
         if(SafeStop>PreSafeStop && BufferEMA[i+1]<BufferEMA[i+2])
            SafeStop=PreSafeStop;
        }
      PreSafeStop=SafeStop;
      BufferESZ[i]=SafeStop;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
