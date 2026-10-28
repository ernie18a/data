//+------------------------------------------------------------------+
//|                                               Sidus_V1_Cloud.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   5
//--- plot LWMA1
#property indicator_label1  "LWMA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LWMA2
#property indicator_label2  "LWMA2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot EMA1
#property indicator_label3  "EMA1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot EMA2
#property indicator_label4  "EMA2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Cloud
#property indicator_label5  "Cloud"
#property indicator_type5   DRAW_FILLING
#property indicator_color5  clrPowderBlue,clrMistyRose
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint                 InpPeriodLWMA1    =  5;             // First LWMA period
input uint                 InpPeriodLWMA2    =  8;             // Second LWMA period
input uint                 InpPeriodEMA1     =  18;            // First EMA period
input uint                 InpPeriodEMA2     =  28;            // Second EMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferLWMA1[];
double         BufferLWMA2[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferCloud1[];
double         BufferCloud2[];
//--- global variables
int            period_lwma1;
int            period_lwma2;
int            period_ema1;
int            period_ema2;
int            handle_lwma1;
int            handle_lwma2;
int            handle_ema1;
int            handle_ema2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_lwma1=int(InpPeriodLWMA1<1 ? 1 : InpPeriodLWMA1);
   period_lwma2=int(InpPeriodLWMA2<1 ? 1 : InpPeriodLWMA2);
   period_ema1=int(InpPeriodEMA1<1 ? 1 : InpPeriodEMA1);
   period_ema2=int(InpPeriodEMA2<1 ? 1 : InpPeriodEMA2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLWMA1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLWMA2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferEMA1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferEMA2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCloud1,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCloud2,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Sidus V1 Cloud ("+(string)period_lwma1+","+(string)period_lwma2+","+(string)period_ema1+","+(string)period_ema2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLWMA1,true);
   ArraySetAsSeries(BufferLWMA2,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferCloud1,true);
   ArraySetAsSeries(BufferCloud2,true);
//--- create MA's handles
   ResetLastError();
   handle_lwma1=iMA(NULL,PERIOD_CURRENT,period_lwma1,0,MODE_LWMA,InpAppliedPrice);
   if(handle_lwma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_lwma1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_lwma2=iMA(NULL,PERIOD_CURRENT,period_lwma2,0,MODE_LWMA,InpAppliedPrice);
   if(handle_lwma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_lwma2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ema1=iMA(NULL,PERIOD_CURRENT,period_ema1,0,MODE_EMA,InpAppliedPrice);
   if(handle_ema1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ema2=iMA(NULL,PERIOD_CURRENT,period_ema2,0,MODE_EMA,InpAppliedPrice);
   if(handle_ema2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema2,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferLWMA1,0);
      ArrayInitialize(BufferLWMA2,0);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferCloud1,0);
      ArrayInitialize(BufferCloud2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_lwma1,0,0,count,BufferLWMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_lwma2,0,0,count,BufferLWMA2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ema1,0,0,count,BufferEMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ema2,0,0,count,BufferEMA2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MaxEMA=fmax(BufferEMA1[i],BufferEMA2[i]);
      double MinEMA=fmin(BufferEMA1[i],BufferEMA2[i]);
      double MaxLWMA=fmax(BufferLWMA1[i],BufferLWMA2[i]);
      double MinLWMA=fmin(BufferLWMA1[i],BufferLWMA2[i]);

      if(MinLWMA>MaxEMA)
        {
         BufferCloud1[i]=MinLWMA;
         BufferCloud2[i]=MaxEMA;
        }
      else if(MinEMA>MaxLWMA)
        {
         BufferCloud1[i]=MaxLWMA;
         BufferCloud2[i]=MinEMA;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
