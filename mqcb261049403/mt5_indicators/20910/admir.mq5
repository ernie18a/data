//+------------------------------------------------------------------+
//|                                                        ADMIR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average Directional Movement Index Rating indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot ADMIR
#property indicator_label1  "ADMIR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // ADX Period
input uint                 InpDifference     =  14;            // Difference 
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferADMIR[];
double         BufferADX1[];
double         BufferADX2[];
//--- global variables
int            period;
int            difference;
int            handle_adx1;
int            handle_adx2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   difference=int(InpDifference<1 ? 1 : InpDifference);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferADMIR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferADX1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferADX2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADM Index Rating ("+(string)period+","+(string)difference+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferADMIR,true);
   ArraySetAsSeries(BufferADX1,true);
   ArraySetAsSeries(BufferADX2,true);
//--- create MA's handles
   ResetLastError();
   handle_adx1=iADX(NULL,PERIOD_CURRENT,period);
   if(handle_adx1==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx2=iADX(NULL,PERIOD_CURRENT,period+difference);
   if(handle_adx2==INVALID_HANDLE)
     {
      Print("The iADX(",string(period+difference),") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferADMIR,EMPTY_VALUE);
      ArrayInitialize(BufferADX1,0);
      ArrayInitialize(BufferADX2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx1,MAIN_LINE,0,count,BufferADX1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx2,MAIN_LINE,0,count,BufferADX2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferADMIR[i]=(BufferADX1[i]+BufferADX2[i])/2.0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
