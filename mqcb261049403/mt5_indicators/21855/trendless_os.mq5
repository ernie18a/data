//+------------------------------------------------------------------+
//|                                                 Trendless_OS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trendless OS DiNapoli indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot TL
#property indicator_label1  "TrendLess"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSteelBlue,clrGreen,clrCornflowerBlue,clrSandyBrown,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_TYPE_DRAWING
  {
   TYPE_DRAWING_LINE =  DRAW_LINE,              // Line
   TYPE_DRAWING_HIST =  DRAW_COLOR_HISTOGRAM    // Histogram
  };
//--- input parameters
input uint                 InpPeriod         =  7;                   // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;         // Applied price
input double               InpOverbought     =  47;                  // Overbought
input double               InpOversold       = -47;                  // Oversold
input ENUM_TYPE_DRAWING    InpTypeDrawing    =  TYPE_DRAWING_HIST;   // Drawing type
//--- indicator buffers
double         BufferTL[];
double         BufferColors[];
double         BufferMA1[];
double         BufferMAP[];
//--- global variables
double         overbought06;
double         overbought08;
double         overbought0;
double         oversold0;
double         oversold08;
double         oversold06;
int            period_ma;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   double overbought=InpOverbought*10.0*Point();
   double oversold=fabs(InpOversold*10.0*Point());
   overbought0=(overbought <10*Point() ? 10*Point() : overbought);
   overbought08=overbought0*0.8;
   overbought06=overbought0*0.6;
   oversold0=(oversold <10*Point() ? 10*Point() : oversold)*-1.0;
   oversold08=oversold0*0.8;
   oversold06=oversold0*0.6;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trendless OS ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overbought08);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,overbought06);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,oversold0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,oversold08);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,5,oversold06);
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpTypeDrawing);
   if(InpTypeDrawing==TYPE_DRAWING_LINE)
     {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,indicator_color1);
      PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1);
     }
   else
      PlotIndexSetInteger(0,PLOT_LINE_WIDTH,indicator_width1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTL,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-1;
      ArrayInitialize(BufferTL,EMPTY_VALUE);
      ArrayInitialize(BufferColors,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTL[i]=BufferMA1[i]-BufferMAP[i];
      BufferColors[i]=
        (
         BufferTL[i]>overbought0 || BufferTL[i]<oversold0 ? 4 :
         (BufferTL[i]<=overbought0 && BufferTL[i]>overbought08) || (BufferTL[i]>=oversold0 && BufferTL[i]<oversold08) ? 3 :
         (BufferTL[i]<=overbought08 && BufferTL[i]>overbought06) || (BufferTL[i]>=oversold08 && BufferTL[i]<oversold06) ? 2 : 1
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
