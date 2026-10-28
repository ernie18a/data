//+------------------------------------------------------------------+
//|                                                   JSmooth_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "JSmooth Moving Average by Mark Jurik"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot JSM
#property indicator_label1  "JSooth"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferJSM[];
double         BufferMA[];
double         BufferA1[];
double         BufferA2[];
double         BufferA3[];
double         BufferA4[];
//--- global variables
double         alpha;
double         alpha2;
double         alpha12;
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   alpha=0.45*(period_ma-1.0)/(0.45*(period_ma-1.0)+2.0);
   alpha2=alpha*alpha;
   alpha12=(1.0-alpha)*(1.0-alpha);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferJSM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferA4,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,234);
   PlotIndexSetInteger(5,PLOT_ARROW,233);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"JSmooth MA ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferJSM,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferA1,true);
   ArraySetAsSeries(BufferA2,true);
   ArraySetAsSeries(BufferA3,true);
   ArraySetAsSeries(BufferA4,true);
//--- create handles
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferJSM,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferA1,0);
      ArrayInitialize(BufferA2,0);
      ArrayInitialize(BufferA3,0);
      ArrayInitialize(BufferA4,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferA1[i]=(1-alpha)*BufferMA[i]+alpha*BufferA1[i+1];
      BufferA2[i]=(1-alpha)*(BufferMA[i]-BufferA1[i])+alpha*BufferA2[i+1];
      BufferA3[i]=BufferA1[i]+BufferA2[i];
      BufferA4[i]=(BufferA3[i]-BufferJSM[i+1])*alpha12+alpha2*BufferA4[i+1];
      BufferJSM[i]=BufferJSM[i+1]+BufferA4[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
