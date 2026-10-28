//+------------------------------------------------------------------+
//|                                                   DI_Cluster.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "DI Cluster indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot DI1
#property indicator_label1  "First DI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DI2
#property indicator_label2  "Second DI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DI3
#property indicator_label3  "Third DI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_MODE
  {
   MODE_ADX,   // ADX
   MODE_DIP,   // +DI
   MODE_DIM    // - DI
  };
//--- input parameters
input ENUM_MODE            InpMode           =  MODE_ADX;      // Lines mode
input uint                 InpPeriod1        =  5;             // First ADX period
input uint                 InpPeriod2        =  8;             // Second ADX period
input uint                 InpPeriod3        =  14;            // Third ADX period
//--- indicator buffers
double         BufferDI1[];
double         BufferDI2[];
double         BufferDI3[];
//--- global variables
int            period1;
int            period2;
int            period3;
int            handle_adx1;
int            handle_adx2;
int            handle_adx3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   string label=(InpMode==MODE_DIM ? "-DI" : InpMode==MODE_DIP ? "+DI" : "ADX");
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period3=int(InpPeriod3<1 ? 1 : InpPeriod3);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDI1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDI2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDI3,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DI Cluster ("+label+","+(string)period1+","+(string)period2+","+(string)period3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"First "+label);
   PlotIndexSetString(1,PLOT_LABEL,"Second "+label);
   PlotIndexSetString(2,PLOT_LABEL,"Third "+label);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDI1,true);
   ArraySetAsSeries(BufferDI2,true);
   ArraySetAsSeries(BufferDI3,true);
//--- create MA's handles
   ResetLastError();
   handle_adx1=iADX(NULL,PERIOD_CURRENT,period1);
   if(handle_adx1==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx2=iADX(NULL,PERIOD_CURRENT,period2);
   if(handle_adx2==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx3=iADX(NULL,PERIOD_CURRENT,period3);
   if(handle_adx3==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period3,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferDI1,EMPTY_VALUE);
      ArrayInitialize(BufferDI2,EMPTY_VALUE);
      ArrayInitialize(BufferDI3,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   int line=(InpMode==MODE_DIM ? MINUSDI_LINE : InpMode==MODE_DIP ? PLUSDI_LINE : MAIN_LINE);
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx1,line,0,count,BufferDI1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx2,line,0,count,BufferDI2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx3,line,0,count,BufferDI3);
   if(copied!=count) return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
