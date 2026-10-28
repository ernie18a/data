//+------------------------------------------------------------------+
//|                                                 StdDev_Cross.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "StdDev Cross indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
//--- plot Dev1
#property indicator_label1  "StdDev1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Dev1
#property indicator_label2  "StdDev2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot CrossUP
#property indicator_label3  "Cross up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot CrossDN
#property indicator_label4  "Cross down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrFuchsia
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint                 InpPeriod1        =  10;            // First MA period
input ENUM_MA_METHOD       InpMethod1        =  MODE_SMA;      // First MA method
input uint                 InpPeriod2        =  20;            // Second MA period
input ENUM_MA_METHOD       InpMethod2        =  MODE_SMA;      // Second MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDev1[];
double         BufferDev2[];
double         BufferCrossUP[];
double         BufferCrossDN[];
double         BufferMAP[];
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
int            period_ma1;
int            period_ma2;
int            period_max;
int            handle_ma1;
int            handle_ma2;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_ma2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_max=fmax(period_ma1,period_ma2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDev1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDev2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCrossUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCrossDN,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMA2,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"StdDev Cross ("+(string)period_ma1+","+(string)period_ma2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDev1,true);
   ArraySetAsSeries(BufferDev2,true);
   ArraySetAsSeries(BufferCrossUP,true);
   ArraySetAsSeries(BufferCrossDN,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_ma1,0,InpMethod1,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_ma2,0,InpMethod2,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferDev1,EMPTY_VALUE);
      ArrayInitialize(BufferDev2,EMPTY_VALUE);
      ArrayInitialize(BufferCrossUP,EMPTY_VALUE);
      ArrayInitialize(BufferCrossDN,EMPTY_VALUE);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA1=BufferMA1[i];
      double MA2=BufferMA2[i];

      double dAmount=0;
      for(int j=0; j<=period_ma1; j++)
        {
         double Pr=BufferMAP[i+j];
         dAmount+=(Pr-MA1)*(Pr-MA1);
        }
      BufferDev1[i]=sqrt(dAmount/(double)period_ma1);

      dAmount=0;
      for(int j=0; j<=period_ma2; j++)
        {
         double Pr=BufferMAP[i+j];
         dAmount+=(Pr-MA2)*(Pr-MA2);
        }
      BufferDev2[i]=sqrt(dAmount/(double)period_ma2);

      BufferCrossUP[i]=BufferCrossDN[i]=EMPTY_VALUE;
      if(BufferDev1[i+1]<BufferDev2[i+1] && BufferDev1[i]>=BufferDev2[i])
         BufferCrossUP[i]=(BufferDev1[i]+BufferDev2[i])/2.0;
      else if(BufferDev1[i+1]>BufferDev2[i+1] && BufferDev1[i]<=BufferDev2[i])
         BufferCrossDN[i]=(BufferDev1[i]+BufferDev2[i])/2.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
