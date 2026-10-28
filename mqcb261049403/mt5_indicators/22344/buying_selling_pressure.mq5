//+------------------------------------------------------------------+
//|                                      Buying_Selling_Pressure.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Buying/Selling Pressure indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot BP
#property indicator_label1  "BP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SP
#property indicator_label2  "SP"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot PT
#property indicator_label3  "PT"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot PS
#property indicator_label4  "PS"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot SBP
#property indicator_label5  "SBP"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLime
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot SSP
#property indicator_label6  "SSP"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrTomato
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_FILTER_TYPE_1
  {
   FILTER1_BOTH,        // Both pressures
   FILTER1_BUYING,      // Buying pressure
   FILTER1_SELLING,     // Selling pressure
   FILTER1_PREVALVING   // Prevailing pressure
  };
//---
enum ENUM_FILTER_TYPE_2
  {
   FILTER2_BOTH,        // Both
   FILTER2_UNSMOOTHED,  // Only unsmoothed
   FILTER2_SMOOTHED     // Only smoothed
  };
//--- input parameters
input uint                 InpPeriod   =  14;   // Period
input uint                 InpPeriodSM =  4;    // Smoothing period
input ENUM_MA_METHOD       InpMethodSM =  0;    // Smoothing method
input ENUM_FILTER_TYPE_1   InpType1    =  3;    // Pressure filter
input ENUM_FILTER_TYPE_2   InpType2    =  2;    // Smoothing filter
//--- indicator buffers
double         BufferBP[];
double         BufferSP[];
double         BufferPT[];
double         BufferPS[];
double         BufferSBP[];
double         BufferSSP[];
//--- global variables
int            period_ma;
int            period_sm;
int            weight_sum_sbp;
int            weight_sum_ssp;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpPeriodSM<2 ? 2 : InpPeriodSM);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BSPressure ("+(string)period_ma+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   if(InpType1==FILTER1_BUYING || InpType1==FILTER1_BOTH)
     {
      if(InpType2==FILTER2_UNSMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(0,BufferBP,INDICATOR_DATA);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(0,PLOT_LABEL,"Buy Pressure");
        }
      else
        {
         SetIndexBuffer(0,BufferBP,INDICATOR_DATA);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(0,PLOT_LABEL,"Buy Pressure");
        }

      if(InpType2==FILTER2_SMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(4,BufferSBP,INDICATOR_DATA);
         PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(4,PLOT_LABEL,"Smooth BuyPrs");
        }
      else
        {
         SetIndexBuffer(4,BufferSBP,INDICATOR_DATA);
         PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(4,PLOT_LABEL,"Smooth BuyPrs");
        }
     }
   else
     {
      SetIndexBuffer(0,BufferBP,INDICATOR_DATA);
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(0,PLOT_LABEL,"Buy Pressure");
      SetIndexBuffer(4,BufferSBP,INDICATOR_DATA);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(4,PLOT_LABEL,"Smooth BuyPrs");
     }

   if(InpType1==FILTER1_SELLING || InpType1==FILTER1_BOTH)
     {
      if(InpType2==FILTER2_UNSMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(1,BufferSP,INDICATOR_DATA);
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(1,PLOT_LABEL,"Sell Pressure");
        }
      else
        {
         SetIndexBuffer(1,BufferSP,INDICATOR_DATA);
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(1,PLOT_LABEL,"Sell Pressure");
        }
      if(InpType2==FILTER2_SMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(5,BufferSSP,INDICATOR_DATA);
         PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(5,PLOT_LABEL,"Smooth SellPrs");
        }
      else
        {
         SetIndexBuffer(5,BufferSSP,INDICATOR_DATA);
         PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(5,PLOT_LABEL,"Smooth SellPrs");
        }
     }
   else
     {
      SetIndexBuffer(1,BufferSP,INDICATOR_DATA);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(1,PLOT_LABEL,"Sell Pressure");
      SetIndexBuffer(5,BufferSSP,INDICATOR_DATA);
      PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(5,PLOT_LABEL,"Smooth SellPrs");
     }

   if(InpType1==FILTER1_PREVALVING || InpType1==FILTER1_BOTH)
     {
      if(InpType2==FILTER2_UNSMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(2,BufferPT,INDICATOR_DATA);
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(2,PLOT_LABEL,"Prevailing");
        }
      else
        {
         SetIndexBuffer(2,BufferPT,INDICATOR_DATA);
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(2,PLOT_LABEL,"Prevailing");
        }
      if(InpType2==FILTER2_SMOOTHED || InpType2==FILTER2_BOTH)
        {
         SetIndexBuffer(3,BufferPS,INDICATOR_DATA);
         PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetString(3,PLOT_LABEL,"Smooth Prv");
        }
      else
        {
         SetIndexBuffer(3,BufferPS,INDICATOR_DATA);
         PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetString(3,PLOT_LABEL,"Smooth Prv");
        }
     }
   else
     {
      SetIndexBuffer(2,BufferPT,INDICATOR_DATA);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(2,PLOT_LABEL,"Prevailing");
      SetIndexBuffer(3,BufferPS,INDICATOR_DATA);
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetString(3,PLOT_LABEL,"Smooth Prv");
     }
     
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBP,true);
   ArraySetAsSeries(BufferSP,true);
   ArraySetAsSeries(BufferPT,true);
   ArraySetAsSeries(BufferPS,true);
   ArraySetAsSeries(BufferSBP,true);
   ArraySetAsSeries(BufferSSP,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferBP,EMPTY_VALUE);
      ArrayInitialize(BufferSP,EMPTY_VALUE);
      ArrayInitialize(BufferPT,EMPTY_VALUE);
      ArrayInitialize(BufferPS,EMPTY_VALUE);
      ArrayInitialize(BufferSBP,EMPTY_VALUE);
      ArrayInitialize(BufferSSP,EMPTY_VALUE);
     }
 
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBP[i] = high[i]-open[i];
      BufferSP[i] = open[i]-low[i];
      BufferPT[i]=(BufferBP[i]>BufferSP[i] ? BufferBP[i] : BufferSP[i]);
     }
   
//--- Расчёт индикатора
   switch(InpMethodSM)
     {
      case MODE_EMA  :
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferBP,BufferSBP)==0) return 0;
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferSP,BufferSSP)==0) return 0;
        break;
      case MODE_SMMA :
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferBP,BufferSBP)==0) return 0;
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferSP,BufferSSP)==0) return 0;
        break;
      case MODE_LWMA :
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferBP,BufferSBP,weight_sum_sbp)==0) return 0;
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferSP,BufferSSP,weight_sum_ssp)==0) return 0;
        break;
      //---MODE_SMA
      default        :
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferBP,BufferSBP)==0) return 0;
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferSP,BufferSSP)==0) return 0;
        break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferPS[i]=(BufferSBP[i]>BufferSSP[i] ? BufferSBP[i] : BufferSSP[i]);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
