//+------------------------------------------------------------------+
//|                                           Rahul_Mohindar_Osc.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Rahul Mohindar oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot RMO
#property indicator_label1  "RMO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLightGreen,clrRed,clrPink,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot UP
#property indicator_label2  "Bullish signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "Bearish signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriodEMA1     =  30;            // First EMA period
input uint                 InpPeriodEMA2     =  30;            // Second EMA period
input uint                 InpPeriodEMA3     =  81;            // Third EMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferRMO[];
double         BufferColors[];
double         BufferUP[];
double         BufferDN[];
double         BufferMA[];
double         BufferSwingTrd[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferEMA3[];
//--- global variables
int            period_1;
int            period_2;
int            period_3;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriodEMA1<2 ? 2 : InpPeriodEMA1);
   period_2=int(InpPeriodEMA2<2 ? 2 : InpPeriodEMA2);
   period_3=int(InpPeriodEMA3<2 ? 2 : InpPeriodEMA3);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRMO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSwingTrd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferEMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferEMA3,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Rahul Mohindar oscillator ("+(string)period_1+","+(string)period_2+","+(string)period_3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRMO,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferSwingTrd,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferEMA3,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_1,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_1,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-12;
      ArrayInitialize(BufferRMO,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferSwingTrd,0);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferEMA3,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Pr0=BufferMA[i];
      double Pr1=BufferMA[i+1];
      double Pr2=BufferMA[i+2];
      double Pr3=BufferMA[i+3];
      double Pr4=BufferMA[i+4];
      double Pr5=BufferMA[i+5];
      double Pr6=BufferMA[i+6];
      double Pr7=BufferMA[i+7];
      double Pr8=BufferMA[i+8];
      double Pr9=BufferMA[i+9];
      double Pr10=BufferMA[i+10];

      double MA1=(Pr0+Pr1)/2.0;
      double MA2=(Pr0+2.0*Pr1+Pr2)/4.0;
      double MA3=(Pr0+3.0*Pr1+3.0*Pr2+Pr3)/8.0;
      double MA4=(Pr0+4.0*Pr1+6.0*Pr2+4.0*Pr3+Pr4)/16.0;
      double MA5=(Pr0+5.0*Pr1+10.0*Pr2+10.0*Pr3+5.0*Pr4+Pr5)/32.0;
      double MA6=(Pr0+6.0*Pr1+15.0*Pr2+20.0*Pr3+15.0*Pr4+6.0*Pr5+Pr6)/64.0;
      double MA7=(Pr0+7.0*Pr1+21.0*Pr2+35.0*Pr3+35.0*Pr4+21.0*Pr5+7.0*Pr6+Pr7)/128.0;
      double MA8=(Pr0+8.0*Pr1+28.0*Pr2+56.0*Pr3+70.0*Pr4+56.0*Pr5+28.0*Pr6+8.0*Pr7+Pr8)/256.0;
      double MA9=(Pr0+9.0*Pr1+36.0*Pr2+84.0*Pr3+126.0*Pr4+126.0*Pr5+84.0*Pr6+36.0*Pr7+9.*Pr8+Pr9)/512.0;
      double MA10=(Pr0+10.0*Pr1+45.0*Pr2+120.0*Pr3+210.0*Pr4+252.0*Pr5+210.0*Pr6+120.0*Pr7+45.0*Pr8+10.0*Pr9+Pr10)/1024.0;

      double Max=fmax(Pr0,fmax(Pr1,fmax(Pr2,fmax(Pr3,fmax(Pr4,fmax(Pr5,fmax(Pr6,fmax(Pr7,fmax(Pr8, Pr9)))))))));
      double Min=fmin(Pr0,fmin(Pr1,fmin(Pr2,fmin(Pr3,fmin(Pr4,fmin(Pr5,fmin(Pr6,fmin(Pr7,fmin(Pr8, Pr9)))))))));
      BufferSwingTrd[i]=(Max!=Min ? 100.0*(Pr0-(MA1+MA2+MA3+MA4+MA5+MA6+MA7+MA8+MA9+MA10)/10.0)/(Max-Min) : 0);
     }
   
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_1,BufferSwingTrd,BufferEMA1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_1,period_2,BufferEMA1,BufferEMA2)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_3,BufferSwingTrd,BufferEMA3)==0)
      return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double EMA2_0=BufferEMA2[i];
      double EMA2_1=BufferEMA2[i+1];
      BufferRMO[i]=BufferEMA3[i]/Point();
      BufferUP[i]=(BufferEMA1[i+1]<EMA2_1 && BufferEMA1[i]>EMA2_0 ? BufferRMO[i] : EMPTY_VALUE);
      BufferDN[i]=(BufferEMA1[i+1]>EMA2_1 && BufferEMA1[i]<EMA2_0 ? BufferRMO[i] : EMPTY_VALUE);
      BufferColors[i]=(BufferRMO[i]>0 ? (BufferEMA1[i]>0 ? 0 : 1) : BufferEMA1[i]>0 ? 3 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
