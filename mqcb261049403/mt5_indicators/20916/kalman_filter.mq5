//+------------------------------------------------------------------+
//|                                                Kalman_Filter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Kalman Filter indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot KF
#property indicator_label1  "Kalman Filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrPurple
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input double               InpK              =  1.0;           // K
input double               InpSharpness      =  1.0;           // Sharpness
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferKF[];
double         BufferMA[];
double         BufferVelocity[];
//--- global variables
double         k;
double         s;
double         shK;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   k=(InpK<0.01 ? 0.01 : InpK);
   s=(InpSharpness<0 ? 0 : InpSharpness);
   shK=sqrt(s*k/100.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferKF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVelocity,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Kalman Filter ("+DoubleToString(k,2)+","+DoubleToString(s,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferKF,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferVelocity,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferKF,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferVelocity,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferVelocity[i]=0;
         BufferKF[i]=BufferMA[i];
        }
      else
        {
         double distance=BufferMA[i]-BufferKF[i+1];
         double error=BufferKF[i+1]+distance*shK;
         BufferVelocity[i]=BufferVelocity[i+1]+distance*k/100.0;
         BufferKF[i]=error+BufferVelocity[i];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
