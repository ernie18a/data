//+------------------------------------------------------------------+
//|                                                         OBOS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Overbought/Oversold Indicator"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   4
//--- plot Up
#property indicator_label1  "Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Down
#property indicator_label2  "Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM2
#property indicator_color3  clrGreen,clrRed,clrBlue,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot Signal
#property indicator_label4  "Signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpPeriod      =  9;       // Period
input double   InpOverbought  =  100.0;   // Overbought
input double   InpOversold    = -100.0;   // Oversold
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferHist1[];
double         BufferHist2[];
double         BufferColors[];
double         BufferSig[];
double         BufferRAW[];
double         BufferAvgRAW[];
double         BufferPrice[];
double         BufferMA[];
double         BufferDev[];
//--- global variables
double         overbought;
double         oversold;
int            period_ma;
int            handle_ma;
int            handle_dev;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold>0 ? 0 : InpOversold);
   overbought=(InpOverbought<0 ? 0 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferHist2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferSig,INDICATOR_DATA);
   SetIndexBuffer(6,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferDev,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,32);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"OBOS ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferHist1,true);
   ArraySetAsSeries(BufferHist2,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSig,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDev,true);
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
      ArrayInitialize(BufferHist1,EMPTY_VALUE);
      ArrayInitialize(BufferHist2,EMPTY_VALUE);
      ArrayInitialize(BufferSig,EMPTY_VALUE);
      ArrayInitialize(BufferColors,3);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDev,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPrice[i]=(high[i]+low[i]+close[i]+close[i])/4.0;
      BufferRAW[i]=(BufferDev[i]!=0 ? (BufferPrice[i]-BufferMA[i])*100.0/BufferDev[i] : 0);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferRAW,BufferAvgRAW)==0)
      return 0;
      
//--- Расчёт индикатора
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferAvgRAW,BufferUP)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferUP,BufferDN)==0)
      return 0;

//--- Сигнальный буфер и цвет
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHist1[i]=BufferUP[i];
      BufferHist2[i]=BufferDN[i];
      BufferSig[i]=0;
      BufferColors[i]=3;
      if(BufferUP[i+1]<BufferUP[i] && BufferDN[i+1]<BufferDN[i])
        {
         BufferSig[i]=Point();
         BufferColors[i]=0;
        }
      else if(BufferUP[i+1]>BufferUP[i] && BufferDN[i+1]>BufferDN[i])
        {
         BufferSig[i]=-Point();
         BufferColors[i]=1;
        }
      else
        {
         BufferSig[i]=0;
         BufferColors[i]=2;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
