//+------------------------------------------------------------------+
//|                                                           DI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Damping index indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot DI
#property indicator_label1  "Damping IDX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  5;          // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
input double         InpLevDmp   =  1.0;        // Damping level
//--- indicator buffers
double         BufferDI[];
double         BufferMAH[];
double         BufferMAL[];
//--- global variables
double         damping_level;
int            period;
int            handle_maH;
int            handle_maL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   damping_level=(InpLevDmp<0 ? 0 : InpLevDmp);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Damping index ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,damping_level);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDI,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create MA's handles
   ResetLastError();
   handle_maH=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_HIGH);
   if(handle_maH==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maL=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_LOW);
   if(handle_maL==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_LOW object was not created: Error ",GetLastError());
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
      limit=rates_total-period-1;
      ArrayInitialize(BufferDI,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maH,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maL,0,0,count,BufferMAL);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double R=BufferMAH[i+period]-BufferMAL[i+period];
      BufferDI[i]=(BufferMAH[i]-BufferMAL[i])/(R!=0 ? R : 1.0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
