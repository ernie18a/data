//+------------------------------------------------------------------+
//|                                                    DZP_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "DZP Trend oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot histogram DZP
#property indicator_label1  "DZP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot line DZP
#property indicator_label2  "DZP"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGreen,clrRed,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- enums
enum ENUM_MODE_VIEW
  {
   MODE_LINE   =  DRAW_LINE,              // Line
   MODE_HIST   =  DRAW_COLOR_HISTOGRAM    // Histogram
  };
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input uint                 InpShift          =  22;            // Shift
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_MODE_VIEW       InpViewMode       =  MODE_LINE;     // Mode view
//--- indicator buffers
double         BufferLine[];
double         BufferDZP[];
double         BufferColors[];
double         BufferMA1[];
double         BufferMAP[];
//--- global variables
int            period;
int            shift;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   shift=int(InpShift<1 ? 1 : InpShift);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLine,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDZP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DZP Trend ("+(string)period+","+(string)shift+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   if(InpViewMode==MODE_LINE)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
     }
   else
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLine,true);
   ArraySetAsSeries(BufferDZP,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMA1,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,MODE_EMA,InpAppliedPrice);
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
   if(rates_total<fmax(shift,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shift-2;
      ArrayInitialize(BufferLine,EMPTY_VALUE);
      ArrayInitialize(BufferDZP,EMPTY_VALUE);
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
      double EMA0=BufferMAP[i];
      double EMAS=BufferMAP[i+shift];
      double Pr0=BufferMA1[i];
      double PrS=BufferMA1[i+shift];

      if(PrS!=0 && EMAS!=0)
        {
         double A=(Pr0-PrS)/PrS;
         double B=(EMA0-EMAS)/EMAS;
         BufferLine[i]=BufferDZP[i]=100.0*(A-B);
        }
      else
        {
         BufferLine[i]=BufferDZP[i]=0;
        }
      BufferColors[i]=(BufferDZP[i]>BufferDZP[i+1] ? 0 : BufferDZP[i]<BufferDZP[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
