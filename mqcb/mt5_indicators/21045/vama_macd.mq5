//+------------------------------------------------------------------+
//|                                                    VAMA_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MACD oscillator by Volume Adjusted Moving Average"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot Histogram
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrLime,clrRed,clrOrange,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input uint                 InpPeriodFastMA   =  12;            // Fast MA period
input uint                 InpPeriodSlowMA   =  26;            // Slow MA period
input uint                 InpPeriodSignal   =  9;             // Signal line period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSignal[];
double         BufferHistogram[];
double         BufferColors[];
double         BufferMA[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sig;
int            period_max;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA==period_fma ? period_fma+1 : InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   period_sig=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
   period_max=fmax(period_sig,fmax(period_fma,period_sma));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHistogram,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VAMA MACD ("+(string)period_fma+","+(string)period_sma+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHistogram,true);
   ArraySetAsSeries(BufferColors,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferHistogram,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
//--- Расчёт MACD
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double S_PV_Short=SumPrVolume(i,period_fma,tick_volume);
      double S_PV_Long=SumPrVolume(i, period_sma,tick_volume);
      double S_V_Short=SumVolume(i, period_fma,tick_volume);
      double S_V_Long=SumVolume(i,period_sma,tick_volume);

      if(S_V_Long!=0. && S_V_Short!=0.)
        {
         double MAS=S_PV_Short/S_V_Short;
         double MAL=S_PV_Long/S_V_Long;
         BufferMACD[i]=MAS-MAL;
        }
     }

//--- Расчёт сигнальной линии и гистограммы
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double S_MACD=SumMACDVolume(i,period_sig,tick_volume);
      double S_V=SumVolume(i,period_sig,tick_volume);
      if(S_V!=0)
        {
         BufferSignal[i]=S_MACD/S_V;
         BufferHistogram[i]=BufferMACD[i]-BufferSignal[i];
         BufferColors[i]=
           (
            BufferHistogram[i]>0 ?
            (BufferHistogram[i]>BufferHistogram[i+1] ? 0 : 1) :
            BufferHistogram[i]<0 ?
            (BufferHistogram[i]<BufferHistogram[i+1] ? 2 : 3) : 4
           );
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Сумма цен и объёмов                                              |
//+------------------------------------------------------------------+
double SumPrVolume(const int index,const int period,const long &volume[])
  {
   double sum=0;
   for(int i=index; i<=index+period-1; i++)
      sum+=BufferMA[i]*volume[i];
   return sum;
  }
//+------------------------------------------------------------------+
//| Сумма значений MACD и объёмов                                    |
//+------------------------------------------------------------------+
double SumMACDVolume(const int index,const int period,const long &volume[])
  {
   double sum=0;
   for(int i=index; i<=index+period-1; i++)
      sum+=BufferMACD[i]*volume[i];
   return sum;
  }
//+------------------------------------------------------------------+
//| Сумма объёмов                                                    |
//+------------------------------------------------------------------+
double SumVolume(const int index,const int period,const long &volume[])
  {
   double sum=0;
   for(int i=index; i<=index+period-1; i++)
      sum+=(double)volume[i];
   return sum;
  }
//+------------------------------------------------------------------+
