//+------------------------------------------------------------------+
//|                                    EMA_With_Trend_Adjustment.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Exponential Smoothing with Trend Adjustment indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot EMATA
#property indicator_label1  "EMATA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input double               InpAlpha          =  0.2;           // Alpha
input double               InpBeta           =  0.3;           // Beta
input ENUM_INPUT_YES_NO    InpEnableTA       =  INPUT_YES;     // Use Trend Adjustment
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferEMATA[];
double         BufferMA[];
double         BufferTA[];
//--- global variables
double         alpha;
double         beta;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   alpha=(InpAlpha<0.05 ? 0.05 : InpAlpha);
   beta=(InpBeta<0.05 ? 0.05 : InpBeta);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferEMATA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"EMATA ("+DoubleToString(alpha,2)+","+DoubleToString(beta,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferEMATA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferTA,true);
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferEMATA,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferTA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferEMATA[i]=alpha*BufferMA[i+1]+(1.0-alpha)*(BufferEMATA[i+1]+BufferTA[i+1]);
      BufferTA[i]=(InpEnableTA ? beta*(BufferEMATA[i]-BufferEMATA[i+1])+(1.0-beta)*BufferTA[i+1] : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
