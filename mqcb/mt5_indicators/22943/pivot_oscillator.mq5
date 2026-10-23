//+------------------------------------------------------------------+
//|                                             Pivot_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Pivot Oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot OSC
#property indicator_label1  "Pivot Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Line
#property indicator_label2  "Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriodFast     =  13;         // Fast MA period
input uint           InpPeriodMedium   =  21;         // Medium MA period
input uint           InpPeriodSlow     =  34;         // Slow MA period
input ENUM_MA_METHOD InpMethod         =  MODE_SMA;   // MA method
//--- indicator buffers
double         BufferOSC[];
double         BufferColors[];
double         BufferLine[];
double         BufferFMA[];
double         BufferMMA[];
double         BufferSMA[];
//--- global variables
int            period_fma;
int            period_mma;
int            period_sma;
int            period_max;
int            handle_fma;
int            handle_mma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_sma=int(InpPeriodSlow==period_fma ? period_fma+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_mma=int(InpPeriodMedium==period_sma ? period_sma+1 : InpPeriodMedium<1 ? 1 : InpPeriodMedium);
   period_max=fmax(period_fma,fmax(period_mma,period_sma));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOSC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferLine,INDICATOR_DATA);
   SetIndexBuffer(3,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Pivot Osc ("+(string)period_fma+","+(string)period_mma+","+(string)period_sma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOSC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferLine,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferMMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethod,PRICE_TYPICAL);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mma=iMA(NULL,PERIOD_CURRENT,period_mma,0,InpMethod,PRICE_TYPICAL);
   if(handle_mma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_mma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethod,PRICE_TYPICAL);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") by object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOSC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferLine,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferMMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mma,0,0,count,BufferMMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double D1=BufferFMA[i]-BufferSMA[i];
      double D2=BufferFMA[i]-BufferSMA[i];
      double D3=BufferFMA[i]-BufferFMA[i];
      double TP=(close[i]+high[i]+low[i])/3.0;
      BufferOSC[i]=BufferLine[i]=(TP!=0 ? (D1+D2+D3)/TP : 0);
      BufferColors[i]=(BufferOSC[i]>BufferOSC[i+1] ? 0 : BufferOSC[i]<BufferOSC[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
