//+------------------------------------------------------------------+
//|                                                           SS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic Stack indicator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   1
//--- plot SS
#property indicator_label1  "SStack"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriodK1          =  36;            // Stoch 1 %K period
input uint     InpPeriodD1          =  18;            // Stoch 1 %D period
input uint     InpSlowing1          =  9;             // Stoch 1 slowing
input ENUM_MA_METHOD InpMethod1     =  MODE_SMA;      // Stoch 1 Method
input ENUM_STO_PRICE InpPriceField1 =  STO_LOWHIGH;   // Stoch 1 Price field

input uint     InpPeriodK2          =  40;            // Stoch 2 %K period
input uint     InpPeriodD2          =  20;            // Stoch 2 %D period
input uint     InpSlowing2          =  10;            // Stoch 2 slowing
input ENUM_MA_METHOD InpMethod2     =  MODE_SMA;      // Stoch 2 Method
input ENUM_STO_PRICE InpPriceField2 =  STO_LOWHIGH;   // Stoch 2 Price field

input uint     InpPeriodK3          =  52;            // Stoch 3 %K period
input uint     InpPeriodD3          =  26;            // Stoch 3 %D period
input uint     InpSlowing3          =  13;            // Stoch 3 slowing
input ENUM_MA_METHOD InpMethod3     =  MODE_SMA;      // Stoch 3 Method
input ENUM_STO_PRICE InpPriceField3 =  STO_LOWHIGH;   // Stoch 3 Price field

input uint     InpPeriodK4          =  60;            // Stoch 4 %K period
input uint     InpPeriodD4          =  30;            // Stoch 4 %D period
input uint     InpSlowing4          =  15;            // Stoch 4 slowing
input ENUM_MA_METHOD InpMethod4     =  MODE_SMA;      // Stoch 4 Method
input ENUM_STO_PRICE InpPriceField4 =  STO_LOWHIGH;   // Stoch 4 Price field

input uint     InpPeriodK5          =  70;            // Stoch 5 %K period
input uint     InpPeriodD5          =  17;            // Stoch 5 %D period
input uint     InpSlowing5          =  8;             // Stoch 5 slowing
input ENUM_MA_METHOD InpMethod5     =  MODE_SMA;      // Stoch 5 Method
input ENUM_STO_PRICE InpPriceField5 =  STO_LOWHIGH;   // Stoch 5 Price field

input uint     InpPeriodK6          =  84;            // Stoch 6 %K period
input uint     InpPeriodD6          =  42;            // Stoch 6 %D period
input uint     InpSlowing6          =  21;            // Stoch 6 slowing
input ENUM_MA_METHOD InpMethod6     =  MODE_SMA;      // Stoch 6 Method
input ENUM_STO_PRICE InpPriceField6 =  STO_LOWHIGH;   // Stoch 6 Price field

input uint     InpPeriodK7          =  100;           // Stoch 7 %K period
input uint     InpPeriodD7          =  50;            // Stoch 7 %D period
input uint     InpSlowing7          =  25;            // Stoch 7 slowing
input ENUM_MA_METHOD InpMethod7     =  MODE_SMA;      // Stoch 7 Method
input ENUM_STO_PRICE InpPriceField7 =  STO_LOWHIGH;   // Stoch 7 Price field

input uint     InpPeriodK8          =  120;           // Stoch 8 %K period
input uint     InpPeriodD8          =  60;            // Stoch 8 %D period
input uint     InpSlowing8          =  30;            // Stoch 8 slowing
input ENUM_MA_METHOD InpMethod8     =  MODE_SMA;      // Stoch 8 Method
input ENUM_STO_PRICE InpPriceField8 =  STO_LOWHIGH;   // Stoch 8 Price field

//--- indicator buffers
double         BufferSS[];
double         BufferColors[];
double         BufferSto1[];
double         BufferSto2[];
double         BufferSto3[];
double         BufferSto4[];
double         BufferSto5[];
double         BufferSto6[];
double         BufferSto7[];
double         BufferSto8[];
//--- global variables
int            period_k1,period_d1,slowing1;
int            period_k2,period_d2,slowing2;
int            period_k3,period_d3,slowing3;
int            period_k4,period_d4,slowing4;
int            period_k5,period_d5,slowing5;
int            period_k6,period_d6,slowing6;
int            period_k7,period_d7,slowing7;
int            period_k8,period_d8,slowing8;
int            handle_sto1;
int            handle_sto2;
int            handle_sto3;
int            handle_sto4;
int            handle_sto5;
int            handle_sto6;
int            handle_sto7;
int            handle_sto8;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k1=int(InpPeriodK1<1 ? 1 : InpPeriodK1);
   period_d1=int(InpPeriodD1<1 ? 1 : InpPeriodD1);
   slowing1=int(InpSlowing1<1 ? 1 : InpSlowing1);
   
   period_k2=int(InpPeriodK2<1 ? 1 : InpPeriodK2);
   period_d2=int(InpPeriodD2<1 ? 1 : InpPeriodD2);
   slowing2=int(InpSlowing2<1 ? 1 : InpSlowing2);
   
   period_k3=int(InpPeriodK3<1 ? 1 : InpPeriodK3);
   period_d3=int(InpPeriodD3<1 ? 1 : InpPeriodD3);
   slowing3=int(InpSlowing3<1 ? 1 : InpSlowing3);
   
   period_k4=int(InpPeriodK4<1 ? 1 : InpPeriodK4);
   period_d4=int(InpPeriodD4<1 ? 1 : InpPeriodD4);
   slowing4=int(InpSlowing4<1 ? 1 : InpSlowing4);
   
   period_k5=int(InpPeriodK5<1 ? 1 : InpPeriodK5);
   period_d5=int(InpPeriodD5<1 ? 1 : InpPeriodD5);
   slowing5=int(InpSlowing5<1 ? 1 : InpSlowing5);
   
   period_k6=int(InpPeriodK6<1 ? 1 : InpPeriodK6);
   period_d6=int(InpPeriodD6<1 ? 1 : InpPeriodD6);
   slowing6=int(InpSlowing6<1 ? 1 : InpSlowing6);
   
   period_k7=int(InpPeriodK7<1 ? 1 : InpPeriodK7);
   period_d7=int(InpPeriodD7<1 ? 1 : InpPeriodD7);
   slowing7=int(InpSlowing7<1 ? 1 : InpSlowing7);
   
   period_k8=int(InpPeriodK8<1 ? 1 : InpPeriodK8);
   period_d8=int(InpPeriodD8<1 ? 1 : InpPeriodD8);
   slowing8=int(InpSlowing8<1 ? 1 : InpSlowing8);
   
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSto1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSto2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSto3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSto4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSto5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSto6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferSto7,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSto8,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic Stack");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSS,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSto1,true);
   ArraySetAsSeries(BufferSto2,true);
   ArraySetAsSeries(BufferSto3,true);
   ArraySetAsSeries(BufferSto4,true);
   ArraySetAsSeries(BufferSto5,true);
   ArraySetAsSeries(BufferSto6,true);
   ArraySetAsSeries(BufferSto7,true);
   ArraySetAsSeries(BufferSto8,true);
//--- create Stochastic's handles
   ResetLastError();
   handle_sto1=iStochastic(NULL,PERIOD_CURRENT,period_k1,period_d1,slowing1,InpMethod1,InpPriceField1);
   if(handle_sto1==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k1,",",(string)period_d1,",",(string)slowing1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto2=iStochastic(NULL,PERIOD_CURRENT,period_k2,period_d2,slowing2,InpMethod2,InpPriceField2);
   if(handle_sto2==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k2,",",(string)period_d2,",",(string)slowing2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto3=iStochastic(NULL,PERIOD_CURRENT,period_k3,period_d3,slowing3,InpMethod3,InpPriceField3);
   if(handle_sto3==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k3,",",(string)period_d3,",",(string)slowing3,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto4=iStochastic(NULL,PERIOD_CURRENT,period_k4,period_d4,slowing4,InpMethod4,InpPriceField4);
   if(handle_sto4==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k4,",",(string)period_d4,",",(string)slowing4,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto5=iStochastic(NULL,PERIOD_CURRENT,period_k5,period_d5,slowing5,InpMethod5,InpPriceField5);
   if(handle_sto5==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k5,",",(string)period_d5,",",(string)slowing5,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto6=iStochastic(NULL,PERIOD_CURRENT,period_k6,period_d6,slowing6,InpMethod6,InpPriceField6);
   if(handle_sto6==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k6,",",(string)period_d6,",",(string)slowing6,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto7=iStochastic(NULL,PERIOD_CURRENT,period_k7,period_d7,slowing7,InpMethod7,InpPriceField7);
   if(handle_sto7==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k7,",",(string)period_d7,",",(string)slowing7,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto8=iStochastic(NULL,PERIOD_CURRENT,period_k8,period_d8,slowing8,InpMethod8,InpPriceField8);
   if(handle_sto8==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k8,",",(string)period_d8,",",(string)slowing8,") object was not created: Error ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferSS,EMPTY_VALUE);
      ArrayInitialize(BufferSto1,0);
      ArrayInitialize(BufferSto2,0);
      ArrayInitialize(BufferSto3,0);
      ArrayInitialize(BufferSto4,0);
      ArrayInitialize(BufferSto5,0);
      ArrayInitialize(BufferSto6,0);
      ArrayInitialize(BufferSto7,0);
      ArrayInitialize(BufferSto8,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sto1,MAIN_LINE,0,count,BufferSto1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto2,MAIN_LINE,0,count,BufferSto2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto3,MAIN_LINE,0,count,BufferSto3);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto4,MAIN_LINE,0,count,BufferSto4);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto5,MAIN_LINE,0,count,BufferSto5);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto6,MAIN_LINE,0,count,BufferSto6);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto7,MAIN_LINE,0,count,BufferSto7);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto8,MAIN_LINE,0,count,BufferSto8);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Stoch1=BufferSto1[i];
      double Stoch2=BufferSto2[i];
      double Stoch3=BufferSto3[i];
      double Stoch4=BufferSto4[i];
      double Stoch5=BufferSto5[i];
      double Stoch6=BufferSto6[i];
      double Stoch7=BufferSto7[i];
      double Stoch8=BufferSto8[i];

      BufferSS[i]=Stoch1-Stoch2+Stoch3-Stoch4+Stoch5-Stoch6+Stoch7-Stoch8;
      BufferColors[i]=(BufferSS[i]>0 ? 0 : BufferSS[i]<0 ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
