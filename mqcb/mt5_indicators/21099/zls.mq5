//+------------------------------------------------------------------+
//|                                                          ZLS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Zero Lag Stochastic indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot Stoch
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input uint           InpSmoothing=15;                 // Smoothing

input uint           InpPeriodK1    =  18;            // Stoch 1 %K period
input uint           InpPeriodD1    =  3;             // Stoch 1 %D period
input uint           InpSlowing1    =  3;             // Stoch 1 Slowing
input ENUM_MA_METHOD InpMethod1      =  MODE_SMA;     // Stoch 1 Method
input ENUM_STO_PRICE InpPriceField1 =  STO_LOWHIGH;   // Stoch 1 Price field
input double         InpWeight1=0.05;                 // Stoch 1 Weight

input uint           InpPeriodK2    =  21;            // Stoch 2 %K period
input uint           InpPeriodD2    =  3;             // Stoch 2 %D period
input uint           InpSlowing2    =  5;             // Stoch 2 Slowing
input ENUM_MA_METHOD InpMethod2      =  MODE_SMA;     // Stoch 2 Method
input ENUM_STO_PRICE InpPriceField2 =  STO_LOWHIGH;   // Stoch 2 Price field
input double         InpWeight2      =  0.1;          // Stoch 2 Weight

input uint           InpPeriodK3    =  34;            // Stoch 3 %K period
input uint           InpPeriodD3    =  3;             // Stoch 3 %D period
input uint           InpSlowing3    =  8;             // Stoch 3 Slowing
input ENUM_MA_METHOD InpMethod3      =  MODE_SMA;     // Stoch 3 Method
input ENUM_STO_PRICE InpPriceField3 =  STO_LOWHIGH;   // Stoch 3 Price field
input double         InpWeight3     =  0.16;          // Stoch 3 Weight

input uint           InpPeriodK4    =  55;            // Stoch 4 %K period
input uint           InpPeriodD4    =  3;             // Stoch 4 %D period
input uint           InpSlowing4    =  13;            // Stoch 4 Slowing
input ENUM_MA_METHOD InpMethod4     =  MODE_SMA;      // Stoch 4 Method
input ENUM_STO_PRICE InpPriceField4 =  STO_LOWHIGH;   // Stoch 4 Price field
input double         InpWeight4     =  0.26;          // Stoch 4 Weight

input uint           InpPeriodK5    =  89;            // Stoch 5 %K period
input uint           InpPeriodD5    =  3;             // Stoch 5 %D period
input uint           InpSlowing5    =  21;            // Stoch 5 Slowing
input ENUM_MA_METHOD InpMethod5     =  MODE_SMA;      // Stoch 5 Method
input ENUM_STO_PRICE InpPriceField5 =  STO_LOWHIGH;   // Stoch 5 Price field
input double         InpWeight5     =  0.43;          // Stoch 5 Weight

//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferST1[];
double         BufferST2[];
double         BufferST3[];
double         BufferST4[];
double         BufferST5[];
//--- global variables
int            period_sm;
int            period_k1,period_d1,period_s1;
int            period_k2,period_d2,period_s2;
int            period_k3,period_d3,period_s3;
int            period_k4,period_d4,period_s4;
int            period_k5,period_d5,period_s5;
int            max_k,max_d,max_s,period_max;
int            handle_st1,handle_st2,handle_st3,handle_st4,handle_st5;
double         smooth_const,sum_weight;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpSmoothing<1 ? 1 : InpSmoothing);
   period_k1=int(InpPeriodK1<1 ? 1 : InpPeriodK1); period_d1=int(InpPeriodD1<1 ? 1 : InpPeriodD1); period_s1=int(InpSlowing1<1 ? 1 : InpSlowing1);
   period_k2=int(InpPeriodK2<1 ? 1 : InpPeriodK2); period_d2=int(InpPeriodD2<1 ? 1 : InpPeriodD2); period_s2=int(InpSlowing2<1 ? 1 : InpSlowing2);
   period_k3=int(InpPeriodK3<1 ? 1 : InpPeriodK3); period_d3=int(InpPeriodD3<1 ? 1 : InpPeriodD3); period_s3=int(InpSlowing3<1 ? 1 : InpSlowing3);
   period_k4=int(InpPeriodK4<1 ? 1 : InpPeriodK4); period_d4=int(InpPeriodD4<1 ? 1 : InpPeriodD4); period_s4=int(InpSlowing4<1 ? 1 : InpSlowing4);
   period_k5=int(InpPeriodK5<1 ? 1 : InpPeriodK5); period_d5=int(InpPeriodD5<1 ? 1 : InpPeriodD5); period_s5=int(InpSlowing5<1 ? 1 : InpSlowing5);
   
   max_k=fmax(period_k1,fmax(period_k2,fmax(period_k3,fmax(period_k4,period_k5))));
   max_d=fmax(period_d1,fmax(period_d2,fmax(period_d3,fmax(period_d4,period_d5))));
   max_s=fmax(period_s1,fmax(period_s2,fmax(period_s3,fmax(period_s4,period_s5))));
   period_max=fmax(period_sm,max_k+max_d+max_s);
   
   smooth_const=(period_sm-1.0)/period_sm;
   sum_weight=InpWeight1+InpWeight2+InpWeight3+InpWeight4+InpWeight5;
   if(sum_weight==0) sum_weight=1.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferST1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferST2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferST3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferST4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferST5,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero Lag Stochastic");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffers parameters
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferST1,true);
   ArraySetAsSeries(BufferST2,true);
   ArraySetAsSeries(BufferST3,true);
   ArraySetAsSeries(BufferST4,true);
   ArraySetAsSeries(BufferST5,true);
//--- create MA's handles
   ResetLastError();
   handle_st1=iStochastic(NULL,PERIOD_CURRENT,period_k1,period_d1,period_s1,InpMethod1,InpPriceField1);
   if(handle_st1==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k1,",",(string)period_d1,",",(string)period_s1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_st2=iStochastic(NULL,PERIOD_CURRENT,period_k2,period_d2,period_s2,InpMethod2,InpPriceField2);
   if(handle_st2==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k2,",",(string)period_d2,",",(string)period_s2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_st3=iStochastic(NULL,PERIOD_CURRENT,period_k3,period_d3,period_s3,InpMethod3,InpPriceField3);
   if(handle_st3==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k3,",",(string)period_d3,",",(string)period_s3,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_st4=iStochastic(NULL,PERIOD_CURRENT,period_k4,period_d4,period_s4,InpMethod4,InpPriceField4);
   if(handle_st4==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k4,",",(string)period_d4,",",(string)period_s4,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_st5=iStochastic(NULL,PERIOD_CURRENT,period_k5,period_d5,period_s5,InpMethod5,InpPriceField5);
   if(handle_st5==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k5,",",(string)period_d5,",",(string)period_s5,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferK,EMPTY_VALUE);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferST1,0);
      ArrayInitialize(BufferST2,0);
      ArrayInitialize(BufferST3,0);
      ArrayInitialize(BufferST4,0);
      ArrayInitialize(BufferST5,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_st1,MAIN_LINE,0,count,BufferST1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_st2,MAIN_LINE,0,count,BufferST2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_st3,MAIN_LINE,0,count,BufferST3);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_st4,MAIN_LINE,0,count,BufferST4);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_st5,MAIN_LINE,0,count,BufferST5);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferK[i]=(BufferST1[i]+BufferST2[i]+BufferST3[i]+BufferST4[i]+BufferST5[i])/sum_weight;
      BufferD[i]=(BufferK[i]/period_sm)+(BufferD[i+1]*smooth_const);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
