//+------------------------------------------------------------------+
//|                                Dinapoli_Preferred_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Dinapoli Preferred Stochastic oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot K
#property indicator_label1  "DPS %K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "DPS %D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodK        =  10;            // %K period
input uint                 InpPeriodD        =  5;             // %D period
input uint                 InpSlowing        =  5;             // Slowing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferMA[];
//--- global variables
int            period_k;
int            period_d;
int            slowing;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Dinapoli Preferred Stochastic ("+(string)period_k+","+(string)period_d+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
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
   if(rates_total<fmax(period_k,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_k-2;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferMA,i,period_k);
      int bh=ArrayMaximum(BufferMA,i,period_k);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferMA[bl];
      double max=BufferMA[bh];

      if(max!=min)
        {
         double fast_k=100.0*(BufferMA[i]-min)/(max-min);
         BufferK[i]=BufferK[i+1]+(fast_k-BufferK[i+1])/slowing;
         BufferD[i]=BufferD[i+1]+(BufferK[i]-BufferD[i+1])/period_d;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
