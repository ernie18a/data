//+------------------------------------------------------------------+
//|                                               ADX_Difference.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ADX Difference indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot ADXD
#property indicator_label1  "Difference"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  14;            // ADX Period
input uint                 InpDifference     =  1;             // Difference 
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferADXD[];
double         BufferColors[];
double         BufferADX[];
//--- global variables
int            period;
int            difference;
int            handle_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   difference=int(InpDifference<1 ? 1 : InpDifference);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferADXD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferADX,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADX Difference ("+(string)period+","+(string)difference+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferADXD,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferADX,true);
//--- create MA's handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period,") object was not created: Error ",GetLastError());
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
      limit=rates_total-difference-1;
      ArrayInitialize(BufferADXD,EMPTY_VALUE);
      ArrayInitialize(BufferADX,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferADXD[i]=BufferADX[i]-BufferADX[i+difference];
      BufferColors[i]=(BufferADXD[i]>BufferADXD[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
