//+------------------------------------------------------------------+
//|                                                      FanCCI2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fan CCI with Average line indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Hist
#property indicator_label1  "FanCCI Hist"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Avg
#property indicator_label2  "FanCCI Avg"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_MODE_INC
  {
   MODE_ADD,      // Addition
   MODE_MLT       // Multiplication
  };
//--- input parameters
input uint                 InpPeriodFirst    =  5;             // First CCI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_TYPICAL; // Applied price
input uint                 InpCountCCI       =  10;            // CCI count
input ENUM_MODE_INC        InpModeInc        =  MODE_ADD;      // Incremental method
input uint                 InpCoeff          =  2;             // Coefficient of increment
input uint                 InpPeriodAvg      =  10;            // Smoothing period
input ENUM_MA_METHOD       InpMethodAvg      =  MODE_SMA;      // Smoothing method
//--- indicator buffers
double         BufferHist[];
double         BufferColors[];
double         BufferAvg[];
double         BufferPrice[];
//--- global variables
int            period_first;
int            period_sm;
int            cnt;
int            coeff;
int            handle_ma;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_first=int(InpPeriodFirst<1 ? 1 : InpPeriodFirst);
   period_sm=int(InpPeriodAvg<2 ? 2 : InpPeriodAvg);
   cnt=int((int)InpCountCCI<1 ? 1 : InpCountCCI);
   uchar k=(InpModeInc==MODE_ADD ? 1 : 2);
   coeff=int(InpCoeff<k ? k : InpCoeff);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferAvg,INDICATOR_DATA);
   SetIndexBuffer(3,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"FanCCI (Periods from "+(string)period_first+", step "+(string)coeff+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits()+1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferAvg,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferHist,0);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferAvg,0);
      ArrayInitialize(BufferPrice,0);
     }

//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;

//--- Расчёт гистограммы
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double s=0;
      int length=period_first;
      for(int j=0; j<cnt; j++)
        {
         double cci0=GetCCI(rates_total,length,i,BufferPrice);
         double cci1=GetCCI(rates_total,length,i+1,BufferPrice);
         if(cci0==0 || cci1==0)
            continue;
         s+=(cci0>cci1 ? 1 : -1);
         if(InpModeInc==MODE_ADD)
            length+=coeff;
         else
            length*=coeff;
        }
      BufferHist[i]=s/cnt;
      BufferColors[i]=(s>0 ? 0 : s<0 ? 1 : 2);
     }

//--- Расчёт средней линии
   switch(InpMethodAvg)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferHist,BufferAvg)==0) return 0;                 break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferHist,BufferAvg)==0) return 0;                    break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferHist,BufferAvg,weight_sum)==0) return 0;   break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferHist,BufferAvg)==0) return 0;                      break;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| GetCCI                                                           |
//+------------------------------------------------------------------+
double GetCCI(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double sum=0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   double dev=SimpleMA(rates_total,period,index,price);
   for(int j=0; j<period; j++)
      sum+=fabs(price[index+j]-dev);
   double meandev=sum/period;
   return(meandev!=0 ? (price[index]-dev)/(meandev*0.015) : 0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SimpleMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
     result=result+price[index+i];
   result/=period;
//---
   return result;
  }
//+------------------------------------------------------------------+
