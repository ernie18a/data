//+------------------------------------------------------------------+
//|                                                     SVE_ARSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Sylvain Vervoort's Asymmetrical RSI"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot ARSI
#property indicator_label1  "SVeARSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  70.0;          // Overbought
input double               InpOversold       =  30.0;          // Oversold
//--- indicator buffers
double         BufferARSI[];
double         BufferMA[];
double         BufferUp[];
double         BufferDn[];
double         BufferUpCnt[];
double         BufferAvgUp[];
double         BufferAvgDn[];
double         BufferAvgUpCnt[];
//--- global variables
double         overbought;
double         oversold;
int            period_ind;
int            period2;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   period2=2*period_ind-1;
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferARSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferUp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferUpCnt,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgUp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgDn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgUpCnt,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SVeARSI ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought/Point());
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold/Point());
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer plot parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_ind-1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferARSI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferUp,true);
   ArraySetAsSeries(BufferDn,true);
   ArraySetAsSeries(BufferUpCnt,true);
   ArraySetAsSeries(BufferAvgUp,true);
   ArraySetAsSeries(BufferAvgDn,true);
   ArraySetAsSeries(BufferAvgUpCnt,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ind,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferARSI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferUp,0);
      ArrayInitialize(BufferDn,0);
      ArrayInitialize(BufferUpCnt,0);
      ArrayInitialize(BufferAvgUp,0);
      ArrayInitialize(BufferAvgDn,0);
      ArrayInitialize(BufferAvgUpCnt,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ROC=(BufferMA[i]-BufferMA[i+1])/Point();
      BufferUp[i]=fmax(ROC,0);
      BufferDn[i]=fabs(fmin(ROC,0));
      BufferUpCnt[i]=(ROC<0 ? 0 : 1);
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferUpCnt,BufferAvgUpCnt)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period2,BufferUp,BufferAvgUp)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period2,BufferDn,BufferAvgDn)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double up=floor(BufferAvgUpCnt[i]*period_ind+0.5);
      double dn=period_ind-up;
      double upmove=(up==0 ? 0 : up==1 ? BufferUp[i] : BufferAvgUp[i]);
      double dnmove=(dn==0 ? 0 : dn==1 ? BufferDn[i] : BufferAvgDn[i]);
      BufferARSI[i]=(dnmove==0 ? 100.0/Point() : (100.0-100.0/(1.0+upmove/dnmove))/Point());
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
