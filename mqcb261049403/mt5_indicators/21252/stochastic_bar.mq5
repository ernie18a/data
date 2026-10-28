//+------------------------------------------------------------------+
//|                                               Stochastic_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic Bar oscillator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot Hist
#property indicator_label1  "Main line;Signal line"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrChartreuse,clrGreen,clrOrange,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot K
#property indicator_label2  "Main line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrChartreuse,clrGreen,clrOrange,clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot D
#property indicator_label3  "Signal line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrChartreuse,clrGreen,clrOrange,clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriodK     =  5;             // %K period
input uint           InpPeriodD     =  3;             // %D period
input uint           InpSlowing     =  3;             // Slowing
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;      // Method
input ENUM_STO_PRICE InpPriceField  =  STO_LOWHIGH;   // Price field
input double         InpOverbought  =  80.0;          // Overbought
input double         InpOversold    =  20.0;          // Oversold
//--- indicator buffers
double         BufferHist1[];
double         BufferHist2[];
double         BufferColorsH[];
double         BufferK[];
double         BufferColorsK[];
double         BufferD[];
double         BufferColorsD[];
double         BufferSTO[];
//--- global variables
double         overbought;
double         oversold;
int            period_k;
int            period_d;
int            slowing;
int            handle_sto;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHist2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferColorsH,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,BufferK,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColorsK,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferD,INDICATOR_DATA);
   SetIndexBuffer(6,BufferColorsD,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,BufferSTO,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic Bar ("+(string)period_k+","+(string)period_d+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist1,true);
   ArraySetAsSeries(BufferHist2,true);
   ArraySetAsSeries(BufferColorsH,true);
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferColorsK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferColorsD,true);
   ArraySetAsSeries(BufferSTO,true);
//--- create MA's handles
   ResetLastError();
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,slowing,InpMethod,InpPriceField);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k,",",(string)period_d,",",(string)slowing,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
      limit=rates_total-1;
      ArrayInitialize(BufferHist1,EMPTY_VALUE);
      ArrayInitialize(BufferHist2,EMPTY_VALUE);
      ArrayInitialize(BufferK,EMPTY_VALUE);
      ArrayInitialize(BufferD,EMPTY_VALUE);
      ArrayInitialize(BufferSTO,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sto,MAIN_LINE,0,count,BufferK);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferD);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHist1[i]=BufferK[i];
      BufferHist2[i]=BufferD[i];
      //---
      if(BufferK[i]>BufferD[i])
        {
         if(BufferK[i]>overbought)
           {
            BufferColorsH[i]=0;
            BufferColorsK[i]=0;
            BufferColorsD[i]=0;
           }
         else
           {
            BufferColorsH[i]=1;
            BufferColorsK[i]=1;
            BufferColorsD[i]=1;
           }
        }
      else
        {
         if(BufferK[i]<oversold)
           {
            BufferColorsH[i]=2;
            BufferColorsK[i]=2;
            BufferColorsD[i]=2;
           }
         else
           {
            BufferColorsH[i]=3;
            BufferColorsK[i]=3;
            BufferColorsD[i]=3;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
