//+------------------------------------------------------------------+
//|                                               Super_Smoother.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ehlers SuperSmoother indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#define   DRAW_BEGIN       (16)
//--- plot SS
#property indicator_label1  "SuperSmoother"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferSS[];
double         BufferMA[];
//--- global variables
int            handle_ma;
double         a1;
double         b1;
double         c2;
double         c3;
double         c1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   a1=exp(-1.414*3.1415926/10.0);
   b1=2.0*a1*cos(1.414*180.0/10.0);
   c2=b1;
   c3=-a1*a1;
   c1=1.0-c2-c3;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Ehlers SuperSmoother");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DRAW_BEGIN);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSS,true);
   ArraySetAsSeries(BufferMA,true);
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
   if(rates_total<DRAW_BEGIN+4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferSS,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferSS[i]=c1*(BufferMA[i]+BufferMA[i+1])/2.0+c2*BufferSS[i+1]+c3*BufferSS[i+2];

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
