//+------------------------------------------------------------------+
//|                                                      Silence.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Silence oscillator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot Aggressiveness
#property indicator_label1  "Aggressiveness"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Volatility
#property indicator_label2  "Volatility"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  12;            // Period
input uint                 InpInterpolation  =  288;           // Interpolation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferAggressiveness[];
double         BufferVolatility[];
double         BufferMA1[];
double         BufferMAP[];
double         BufferSizeArray[];
double         BufferAvgSizeArray[];
double         BufferAggress[];
double         BufferVol[];
//--- global variables
int            period_ma;
int            interpolation;
int            handle_ma1;
int            handle_maP;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   interpolation=int(InpInterpolation<2 ? 2 : InpInterpolation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAggressiveness,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVolatility,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSizeArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgSizeArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAggress,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Silence ("+(string)period_ma+","+(string)interpolation+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAggressiveness,true);
   ArraySetAsSeries(BufferVolatility,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferSizeArray,true);
   ArraySetAsSeries(BufferAvgSizeArray,true);
   ArraySetAsSeries(BufferAggress,true);
   ArraySetAsSeries(BufferVol,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
   if(rates_total<fmax(period_ma,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferAggressiveness,EMPTY_VALUE);
      ArrayInitialize(BufferVolatility,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferSizeArray,0);
      ArrayInitialize(BufferAvgSizeArray,0);
      ArrayInitialize(BufferAggress,0);
      ArrayInitialize(BufferVol,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferSizeArray[i]=fabs(BufferMA1[i]-BufferMA1[i+1]);
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferSizeArray,BufferAvgSizeArray)==0)
      return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double B=BufferAvgSizeArray[i];
      double dAmount=0;
      double Avg=BufferMAP[i];
      for(int j=i+period_ma-1; j>=i; j--)
         dAmount+=pow(BufferMA1[j]-Avg,2.0);
      dAmount/=period_ma;

      BufferAggress[i]=B/Point();
      BufferVol[i]=sqrt(dAmount);
     }

//--- Расчёт индикатора
   double max_limit=100.0;
   double min_limit=0.0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferAggress,i,interpolation);
      int bh=ArrayMaximum(BufferAggress,i,interpolation);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferAggress[bl];
      double max=BufferAggress[bh];
      BufferAggressiveness[i]=Interpolation(max,min,max_limit,min_limit,BufferAggress[i]);

      bl=ArrayMinimum(BufferVol,i,interpolation);
      bh=ArrayMaximum(BufferVol,i,interpolation);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      min=BufferVol[bl];
      max=BufferVol[bh];

      BufferVolatility[i]=Interpolation(max,min,max_limit,min_limit,BufferVol[i]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Interpolation                                                    |
//+------------------------------------------------------------------+
double Interpolation(const double a,const double b,const double c,const double d,const double X)
  {
   return(a==b ? 1000000.0 : (d-(b-X)*(d-c)/(b-a)));
  }
//+------------------------------------------------------------------+
