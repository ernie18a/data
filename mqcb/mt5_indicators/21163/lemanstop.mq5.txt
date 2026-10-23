//+------------------------------------------------------------------+
//|                                                    LeManStop.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "LeMan Stop indicator"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   2
//--- plot LeManUP
#property indicator_label1  "LeMan Bullish"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LeManDN
#property indicator_label2  "LeMan Bearish"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriod         =  24;         // Period
input uint           InpCoeff          =  4;          // Coefficient
input uint           InpPeriodFastMA   =  9;          // Fast MA period
input ENUM_MA_METHOD InpMethodFastMA   =  MODE_SMA;   // Fast MA method
input uint           InpPeriodSlowMA   =  18;         // Slow MA period
input ENUM_MA_METHOD InpMethodSlowMA   =  MODE_SMA;   // Slow MA method
//--- indicator buffers
double         BufferLeManUP[];
double         BufferLeManDN[];
double         BufferLeMan[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferHO[];
double         BufferOL[];
double         BufferAvgHO[];
double         BufferAvgOL[];
//--- global variables
int            period_ind;
int            period_fma;
int            period_sma;
int            handle_fma;
int            handle_sma;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLeManUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLeManDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLeMan,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferHO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferOL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgHO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferAvgOL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LeMan Stop ("+(string)period_ind+","+(string)period_fma+","+(string)period_sma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLeManUP,true);
   ArraySetAsSeries(BufferLeManDN,true);
   ArraySetAsSeries(BufferLeMan,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferHO,true);
   ArraySetAsSeries(BufferOL,true);
   ArraySetAsSeries(BufferAvgHO,true);
   ArraySetAsSeries(BufferAvgOL,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethodFastMA,PRICE_CLOSE);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethodSlowMA,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
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
      limit=rates_total-2;
      ArrayInitialize(BufferLeManUP,EMPTY_VALUE);
      ArrayInitialize(BufferLeManDN,EMPTY_VALUE);
      ArrayInitialize(BufferLeMan,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferHO,0);
      ArrayInitialize(BufferOL,0);
      ArrayInitialize(BufferAvgHO,0);
      ArrayInitialize(BufferAvgOL,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHO[i]=high[i]-open[i];
      BufferOL[i]=open[i]-low[i];
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferHO,BufferAvgHO)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferOL,BufferAvgOL)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double EMA0=BufferFMA[i]-BufferSMA[i];
      double EMA1=BufferFMA[i+1]-BufferSMA[i+1];
      double PreStop=BufferLeMan[i+1];
      double Stop=PreStop;

      if(EMA0>0)
        {
         double x=BufferAvgHO[i];
         Stop=open[i]-InpCoeff*x;
         if(Stop<PreStop && EMA1>0)
            Stop=PreStop;
        }
      else if(EMA0<0)
        {
         double x=BufferAvgOL[i];
         Stop=open[i+1]+InpCoeff*x;
         if(Stop>PreStop && EMA1<0)
            Stop=PreStop;
        }
      BufferLeMan[i]=Stop;
      
      if(BufferLeMan[i]>close[i])
        {
         BufferLeManDN[i]=BufferLeMan[i];
         BufferLeManDN[i+1]=BufferLeMan[i+1];
         BufferLeManUP[i]=EMPTY_VALUE;
        }
      else
        {
         BufferLeManUP[i]=BufferLeMan[i];
         BufferLeManUP[i+1]=BufferLeMan[i+1];
         BufferLeManDN[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
