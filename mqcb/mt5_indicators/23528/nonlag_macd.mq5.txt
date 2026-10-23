//+------------------------------------------------------------------+
//|                                                  NonLag_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Non lag MACD oscillator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot MACD
#property indicator_label1  "NonLag MACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrDodgerBlue,clrRed,clrFuchsia,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  8
//--- plot Signal
#property indicator_label2  "NL MACD Signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDodgerBlue,clrOrangeRed,clrSlateGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint                 InpPeriodFast     =  5;             // Fast NonLag period
input uint                 InpPeriodSlow     =  11;            // Slow NonLag period
input uint                 InpPeriodSignal   =  9;             // Signal period
input ENUM_MA_METHOD       InpMethodFast     =  MODE_SMA;      // Fast NonLag method
input ENUM_MA_METHOD       InpMethodSlow     =  MODE_SMA;      // Slow NonLag method
input ENUM_MA_METHOD       InpMethodSignal   =  MODE_SMA;      // Signal method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpFilter         =  0;             // Filter
input double               InpDeviation      =  0.0;           // Deviation (price)
//--- indicator buffers
double         BufferMACD[];
double         BufferColorsMACD[];
double         BufferSignal[];
double         BufferColorsSignal[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferFNL[];
double         BufferSNL[];
//--- global variables
double         deviation;
double         coeff;
double         phase_fast;
double         len_fast;
double         dt1_fast;
double         dt2_fast;
double         phase_slow;
double         len_slow;
double         dt1_slow;
double         dt2_slow;
double         kd;
double         filter;
int            period_fast;
int            period_slow;
int            period_sig;
int            handle_fma;
int            handle_sma;
int            period_max;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<3 ? 3 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<3 ? 3 : InpPeriodSlow);
   period_sig=int(InpPeriodSignal<2 ? 2 : InpPeriodSignal);
   deviation=InpDeviation;
   filter=(double)InpFilter*Point();
   coeff=3.0*M_PI;
   kd=1.0+deviation/100.0;
   phase_fast=period_fast-1;
   len_fast=4.0*period_fast+phase_fast;
   dt1_fast=7.0/(4.0*period_fast-1.0);
   dt2_fast=1.0/(phase_fast-1.0);
   phase_slow=period_sig-1;
   len_slow=4.0*period_slow+phase_slow;
   dt1_slow=7.0/(4.0*period_slow-1.0);
   dt2_slow=1.0/(phase_slow-1.0);
   period_max=(int)fmax(period_sig,fmax(len_fast+period_fast,len_slow+period_slow));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsMACD,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsSignal,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFNL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSNL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Non lag MACD ("+(string)period_fast+","+(string)period_slow+","+(string)period_sig+","+(string)InpFilter+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferColorsMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferColorsSignal,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferFNL,true);
   ArraySetAsSeries(BufferSNL,true);
//--- create MA handle
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,InpMethodFast,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA (",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,InpMethodSlow,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA (",(string)period_slow,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferColorsMACD,4);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferColorsSignal,2);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferFNL,0);
      ArrayInitialize(BufferSNL,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      NonLag(rates_total,i,(int)len_fast,dt1_fast,dt2_fast,BufferFMA,BufferFNL);
      NonLag(rates_total,i,(int)len_slow,dt1_slow,dt2_slow,BufferSMA,BufferSNL);
      BufferMACD[i]=BufferFNL[i]-BufferSNL[i];
      BufferColorsMACD[i]=
        (
         BufferMACD[i]>0 ? (BufferMACD[i]>BufferMACD[i+1] ? 0 : BufferMACD[i]<BufferMACD[i+1] ? 1 : (filter>0 ? BufferColorsMACD[i+1] : 4)) :
         BufferMACD[i]<0 ? (BufferMACD[i]<BufferMACD[i+1] ? 2 : BufferMACD[i]>BufferMACD[i+1] ? 3 : (filter>0 ? BufferColorsMACD[i+1] : 4)) : 4
        );
     }
   switch(InpMethodSignal)
     {
      case MODE_EMA  : if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferMACD,BufferSignal)==0) return 0; break;
      case MODE_SMMA : if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferMACD,BufferSignal)==0) return 0; break;
      case MODE_LWMA : if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferMACD,BufferSignal,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        : if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferMACD,BufferSignal)==0) return 0; break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferColorsSignal[i]=(BufferSignal[i]>BufferSignal[i+1] ? 0 : BufferSignal[i]<BufferSignal[i+1] ? 1 : 2);
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| NonLag                                                           |
//+------------------------------------------------------------------+
void NonLag(const int rates_total,const int shift,const int length,const double dt1,const double dt2,const double &buffer_ma[],double &buffer_nl[])
  {
   double weight=0,sum=0,t=0;
   if(shift+length>rates_total-1)
      return;
   for(int j=0; j<length; j++)
     {
      double g=1.0/(coeff*t+1);
      if(t<=0.5) g=1;
      double beta=cos(M_PI*t);
      double alpha=g*beta;
      sum+=alpha*buffer_ma[shift+j];
      weight+=alpha;
      if(t<1.0) t+=dt2; else if(t<length-1) t=+dt1;
     }
   if(weight>0)
      buffer_nl[shift]=kd*sum/weight;
   if(filter>0 && fabs(buffer_nl[shift]-buffer_nl[shift+1])<filter)
      buffer_nl[shift]=buffer_nl[shift+1];
  }
//+------------------------------------------------------------------+
