//+------------------------------------------------------------------+
//|                              Customizable_Awesome_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Customizable BW Awesome Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot AO
#property indicator_label1  "CAO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodFast     =  5;             // MA Fast period
input uint                 InpPeriodSlow     =  35;            // MA Slow period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferAO[];
double         BufferColors[];
double         BufferMAF[];
double         BufferMAS[];
//--- global variables
int            period_fast;
int            period_slow;
int            handle_maf;
int            handle_mas;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAS,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CAO("+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAO,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAF,true);
   ArraySetAsSeries(BufferMAS,true);
//--- create MA fast handle
   ResetLastError();
   handle_maf=iMA(NULL,PERIOD_CURRENT,period_fast,0,InpMethod,InpAppliedPrice);
   if(handle_maf==INVALID_HANDLE)
     {
      Print("The Fast iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create MA slow handle
   ResetLastError();
   handle_mas=iMA(NULL,PERIOD_CURRENT,period_slow,0,InpMethod,InpAppliedPrice);
   if(handle_mas==INVALID_HANDLE)
     {
      Print("The Slow iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferAO,EMPTY_VALUE);
      ArrayInitialize(BufferMAF,0);
      ArrayInitialize(BufferMAS,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_maf,0,0,count,BufferMAF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mas,0,0,count,BufferMAS);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferAO[i]=BufferMAF[i]-BufferMAS[i];
      BufferColors[i]=(BufferAO[i]>BufferAO[i+1] ? 0 : 1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
