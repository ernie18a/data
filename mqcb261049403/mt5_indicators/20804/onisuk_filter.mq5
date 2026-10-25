//+------------------------------------------------------------------+
//|                                                Onisuk_Filter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              https://mql5.com/ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Onisuk Filter Helper indicator"
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   6
//--- plot UP 1
#property indicator_label1  "Scenario 1 UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN 1
#property indicator_label2  "Scenario 1 DN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot UP 2
#property indicator_label3  "Scenario 2 UP"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot DN 2
#property indicator_label4  "Scenario 2 DN"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- plot UP 3
#property indicator_label5  "Scenario 3 UP"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot DN 3
#property indicator_label6  "Scenario 3 DN"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpUseSC1   =  INPUT_YES;  // Use scenario 1 "Power Trend"
input uint              InpPeriod11 =  3;          // Scenario 1, Period 1
input ENUM_MA_METHOD    InpMethod11 =  MODE_EMA;   // Scenario 1, Method 1
input uint              InpPeriod12 =  7;          // Scenario 1, Period 2
input ENUM_MA_METHOD    InpMethod12 =  MODE_EMA;   // Scenario 1, Method 2
input uint              InpPeriod13 =  50;         // Scenario 1, Period 3
input ENUM_MA_METHOD    InpMethod13 =  MODE_EMA;   // Scenario 1, Method 3

input ENUM_INPUT_YES_NO InpUseSC2   =  INPUT_NO;   // Use scenario 2 "Medium MA Bounce"
input uint              InpPeriod21 =  20;         // Scenario 2, Period 1
input ENUM_MA_METHOD    InpMethod21 =  MODE_EMA;   // Scenario 2, Method 1
input uint              InpPeriod22 =  50;         // Scenario 2, Period 2
input ENUM_MA_METHOD    InpMethod22 =  MODE_EMA;   // Scenario 2, Method 2

input ENUM_INPUT_YES_NO InpUseSC3   =  INPUT_NO;   // Use scenario 3 "Slow MA Bounce"
input uint              InpPeriod31 =  20;         // Scenario 3, Period 1
input ENUM_MA_METHOD    InpMethod31 =  MODE_EMA;   // Scenario 3, Method 1
input uint              InpPeriod32 =  50;         // Scenario 3, Period 2
input ENUM_MA_METHOD    InpMethod32 =  MODE_EMA;   // Scenario 3, Method 2

//--- indicator buffers
double         BufferUP1[];
double         BufferDN1[];
double         BufferUP2[];
double         BufferDN2[];
double         BufferUP3[];
double         BufferDN3[];
double         BufferMA11[];
double         BufferMA12[];
double         BufferMA13[];
double         BufferMA21[];
double         BufferMA22[];
double         BufferMA31[];
double         BufferMA32[];
double         BufferATR[];
//--- global variables
int            period11;
int            period12;
int            period13;
int            period21;
int            period22;
int            period31;
int            period32;
int            period_atr;
int            handle_ma11;
int            handle_ma12;
int            handle_ma13;
int            handle_ma21;
int            handle_ma22;
int            handle_ma31;
int            handle_ma32;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=14;
   period11=int(InpPeriod11<1 ? 1 : InpPeriod11);
   period12=int(InpPeriod12<1 ? 1 : InpPeriod12);
   period13=int(InpPeriod13<1 ? 1 : InpPeriod13);
   period21=int(InpPeriod21<1 ? 1 : InpPeriod21);
   period22=int(InpPeriod22<1 ? 1 : InpPeriod22);
   period31=int(InpPeriod31<1 ? 1 : InpPeriod31);
   period32=int(InpPeriod32<1 ? 1 : InpPeriod32);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUP2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferUP3,INDICATOR_DATA);
   SetIndexBuffer(5,BufferDN3,INDICATOR_DATA);
   SetIndexBuffer(6,BufferMA11,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMA12,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMA13,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMA21,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMA22,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferMA31,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferMA32,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferATR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,241);
   PlotIndexSetInteger(1,PLOT_ARROW,242);
   PlotIndexSetInteger(2,PLOT_ARROW,241);
   PlotIndexSetInteger(3,PLOT_ARROW,242);
   PlotIndexSetInteger(4,PLOT_ARROW,241);
   PlotIndexSetInteger(5,PLOT_ARROW,242);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Onisuk Filter Helper");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP1,true);
   ArraySetAsSeries(BufferDN1,true);
   ArraySetAsSeries(BufferUP2,true);
   ArraySetAsSeries(BufferDN2,true);
   ArraySetAsSeries(BufferUP3,true);
   ArraySetAsSeries(BufferDN3,true);
//---
   ArraySetAsSeries(BufferMA11,true);
   ArraySetAsSeries(BufferMA12,true);
   ArraySetAsSeries(BufferMA13,true);
   ArraySetAsSeries(BufferMA21,true);
   ArraySetAsSeries(BufferMA22,true);
   ArraySetAsSeries(BufferMA31,true);
   ArraySetAsSeries(BufferMA32,true);
   ArraySetAsSeries(BufferATR,true);
//--- create ATR and MA handles
   ResetLastError();
   handle_ma11=iMA(NULL,PERIOD_CURRENT,period11,0,InpMethod11,PRICE_CLOSE);
   if(handle_ma11==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period11,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma12=iMA(NULL,PERIOD_CURRENT,period12,0,InpMethod12,PRICE_CLOSE);
   if(handle_ma12==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period12,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma13=iMA(NULL,PERIOD_CURRENT,period13,0,InpMethod13,PRICE_CLOSE);
   if(handle_ma13==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period13,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }

   handle_ma21=iMA(NULL,PERIOD_CURRENT,period21,0,InpMethod21,PRICE_CLOSE);
   if(handle_ma21==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period21,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma22=iMA(NULL,PERIOD_CURRENT,period22,0,InpMethod22,PRICE_CLOSE);
   if(handle_ma22==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period22,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }

   handle_ma31=iMA(NULL,PERIOD_CURRENT,period31,0,InpMethod31,PRICE_CLOSE);
   if(handle_ma31==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period31,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma32=iMA(NULL,PERIOD_CURRENT,period32,0,InpMethod32,PRICE_CLOSE);
   if(handle_ma32==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period32,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUP1,EMPTY_VALUE);
      ArrayInitialize(BufferDN1,EMPTY_VALUE);
      ArrayInitialize(BufferUP2,EMPTY_VALUE);
      ArrayInitialize(BufferDN2,EMPTY_VALUE);
      ArrayInitialize(BufferUP3,EMPTY_VALUE);
      ArrayInitialize(BufferDN3,EMPTY_VALUE);
      //---
      ArrayInitialize(BufferMA11,0);
      ArrayInitialize(BufferMA12,0);
      ArrayInitialize(BufferMA13,0);
      ArrayInitialize(BufferMA21,0);
      ArrayInitialize(BufferMA22,0);
      ArrayInitialize(BufferMA31,0);
      ArrayInitialize(BufferMA32,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma11,0,0,count,BufferMA11);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma12,0,0,count,BufferMA12);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma13,0,0,count,BufferMA13);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma21,0,0,count,BufferMA21);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma22,0,0,count,BufferMA22);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma31,0,0,count,BufferMA31);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma32,0,0,count,BufferMA32);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP1[i]=BufferDN1[i]=BufferUP2[i]=BufferDN2[i]=BufferUP3[i]=BufferDN3[i]=EMPTY_VALUE;
      int res1=GetData1(i,open,close);
      int res2=GetData2(i,open,high,low,close);
      int res3=GetData3(i,open,high,low,close);
      if(res1==1) BufferUP1[i]=low[i]-BufferATR[i]/2.0;
      if(res2==1) BufferUP2[i]=low[i]-BufferATR[i]/2.0;
      if(res3==1) BufferUP3[i]=low[i]-BufferATR[i]/2.0;
      if(res1==-1) BufferDN1[i]=high[i]+BufferATR[i]/2.0;
      if(res2==-1) BufferDN2[i]=high[i]+BufferATR[i]/2.0;
      if(res3==-1) BufferDN3[i]=high[i]+BufferATR[i]/2.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает условия сценария 1                                    |
//+------------------------------------------------------------------+
int GetData1(const int index,const double &open[],const double &close[])
  {
   if(!InpUseSC1)
      return 0;
   double MA1=BufferMA11[index];
   double MA2=BufferMA12[index];
   double MA3=BufferMA13[index];
   return(MA1>MA2 && MA2>MA3 && close[index]<open[index] ? 1 : MA1<MA2 && MA2<MA3 && close[index]<open[index] ? -1 : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает условия сценария 2                                    |
//+------------------------------------------------------------------+
int GetData2(const int index,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   if(!InpUseSC2)
      return 0;
   double MA1=BufferMA21[index];
   double MA2=BufferMA22[index];
   return(MA1>MA2 && low[index]<MA1 && open[index]>MA1 && close[index]>MA1 ? 1 : MA1<MA2 && high[index]>MA1 && open[index]<MA1 && close[index]<MA1 ? -1 : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает условия сценария 3                                    |
//+------------------------------------------------------------------+
int GetData3(const int index,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   if(!InpUseSC3)
      return 0;
   double MA1=BufferMA31[index];
   double MA2=BufferMA32[index];
   return(MA1>MA2 && low[index]<MA2 && open[index]>MA2 && close[index]>MA2 ? 1 : MA1<MA2 && high[index]>MA2 && open[index]<MA2 && close[index]<MA2 ? -1 : 0);
  }
//+------------------------------------------------------------------+
