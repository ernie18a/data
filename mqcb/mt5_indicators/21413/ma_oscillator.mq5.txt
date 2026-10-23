//+------------------------------------------------------------------+
//|                                                MA_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MA Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MAO
#property indicator_label1  "MAOsc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMAO[];
double         BufferColors[];
double         BufferMAP[];
double         BufferMA1[];
//--- global variables
int            period;
int            handle_maP;
int            handle_ma1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMAO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string method=StringSubstr(EnumToString(InpMethod),5);
   IndicatorSetString(INDICATOR_SHORTNAME,method+" Oscillator ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMAO,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMA1,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMAO,EMPTY_VALUE);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMA1,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=BufferMAP[i];
      BufferMAO[i]=(MA!=0 ? BufferMA1[i]/MA-1.0 : 0);
      BufferColors[i]=(BufferMAO[i]>BufferMAO[i+1] ? 0 : BufferMAO[i]<BufferMAO[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
