//+------------------------------------------------------------------+
//|                              Normalized_Moving_Average_Slope.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Normalized Moving Average Slope"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot NMAS
#property indicator_label1  "NMAS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodMA       =  14;            // MA period
input uint                 InpPeriodATR      =  14;            // ATR period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferNMAS[];
double         BufferATR[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            period_atr;
int            handle_ma;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferNMAS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized MA Slope ("+(string)period_ma+","+(string)period_atr+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferNMAS,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferNMAS,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferNMAS[i]=(BufferATR[i]!=0 ? 100.0*(BufferMA[i]-BufferMA[i+1])/BufferATR[i] : 0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
