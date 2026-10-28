//+------------------------------------------------------------------+
//|                                           CCI_OBOS_Crossover.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "CCI OBOS Crossover indicator"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "CCI OBOS Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "CCI OBOS Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodOBOS  =  9;          // OBOS period
input uint              InpPeriodCCI   =  14;         // CCI period
input ENUM_INPUT_YES_NO InpUseFilter   =  INPUT_NO;   // Use OB/OS filter
input double            InpOverbought  =  50.0;       // Overbought
input double            InpOversold    = -50.0;       // Oversold
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferObOsUP[];
double         BufferObOsDN[];
double         BufferRAW[];
double         BufferAvgRAW[];
double         BufferPrice[];
double         BufferMA[];
double         BufferDev[];
double         BufferCCI[];
//--- global variables
double         overbought;
double         oversold;
int            period_ma;
int            period_cci;
int            handle_ma;
int            handle_dev;
int            handle_cci;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodOBOS<1 ? 1 : InpPeriodOBOS);
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   oversold=(InpOversold>0 ? 0 : InpOversold);
   overbought=(InpOverbought<0 ? 0 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferObOsUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferObOsDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferCCI,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI OBOS Crossover ("+(string)period_ma+","+(string)period_cci+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferObOsUP,true);
   ArraySetAsSeries(BufferObOsDN,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_EMA,PRICE_WEIGHTED);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_ma,0,MODE_EMA,PRICE_WEIGHTED);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferObOsUP,0);
      ArrayInitialize(BufferObOsDN,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDev,0);
      ArrayInitialize(BufferCCI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPrice[i]=(high[i]+low[i]+close[i]+close[i])/4.0;
      BufferRAW[i]=(BufferDev[i]!=0 ?(BufferPrice[i]-BufferMA[i])*100.0/BufferDev[i]: 0);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferRAW,BufferAvgRAW)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferAvgRAW,BufferObOsUP)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferObOsUP,BufferObOsDN)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double cci0=BufferCCI[i];
      double cci1=BufferCCI[i+1];

      double obos_up0=BufferObOsUP[i];
      double obos_up1=BufferObOsUP[i+1];
      double obos_dn0=BufferObOsDN[i];
      double obos_dn1=BufferObOsDN[i+1];

      if(cci1<obos_up1 && cci0>obos_up0 && (!InpUseFilter || (InpUseFilter && obos_dn0<oversold)))
         BufferUP[i]=open[i];
      else
         BufferUP[i]=EMPTY_VALUE;

      if(cci1>obos_dn1 && cci0<obos_dn0 && (!InpUseFilter || (InpUseFilter && obos_up0>overbought)))
         BufferDN[i]=open[i];
      else
         BufferDN[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
