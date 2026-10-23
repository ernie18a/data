//+------------------------------------------------------------------+
//|                                                        Notis.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Notis% V indicators"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot Plus
#property indicator_label1  "Plus"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Minus
#property indicator_label2  "Minus"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Notis
#property indicator_label3  "Notis"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  14;         // Period
input ENUM_MA_METHOD    InpMethod      =  MODE_SMA;   // Method
input ENUM_INPUT_YES_NO InpCumulative  =  INPUT_NO;   // Cumulative mode
input ENUM_INPUT_YES_NO InpInverse     =  INPUT_NO;   // Inverse in cumulative mode
//--- indicator buffers
double         BufferPlus[];
double         BufferMinus[];
double         BufferNotis[];
double         BufferP[];
double         BufferM[];
//--- global variables
int            period_ind;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPlus,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMinus,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNotis,INDICATOR_DATA);
   SetIndexBuffer(3,BufferP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferM,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Notis ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPlus,true);
   ArraySetAsSeries(BufferMinus,true);
   ArraySetAsSeries(BufferNotis,true);
   ArraySetAsSeries(BufferP,true);
   ArraySetAsSeries(BufferM,true);
//---
   if(InpCumulative)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(2,PLOT_SHOW_DATA,true);
      ChartRedraw();
     }
   else
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
      PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
      ChartRedraw();
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferPlus,EMPTY_VALUE);
      ArrayInitialize(BufferMinus,EMPTY_VALUE);
      ArrayInitialize(BufferNotis,EMPTY_VALUE);
      ArrayInitialize(BufferP,0);
      ArrayInitialize(BufferM,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferP[i]=high[i]-close[i];
      BufferM[i]=close[i]-low[i];
     }
   switch(InpMethod)
     {
      case MODE_EMA : 
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferP,BufferPlus);
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferM,BufferMinus);
        break;
      case MODE_SMMA : 
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferP,BufferPlus);
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferM,BufferMinus);
        break;
      case MODE_LWMA : 
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferP,BufferPlus,weight_sum);
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferM,BufferMinus,weight_sum);
        break;
      default:
        //--- SMA
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferP,BufferPlus);
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferM,BufferMinus);
        break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Plus=BufferPlus[i];
      double Minus=BufferMinus[i];
      if(InpCumulative && Plus+Minus>0)
        {
         BufferNotis[i]=100.0*Plus/(Plus+Minus);
         if(InpInverse) BufferNotis[i]=100-BufferNotis[i];
        }
      else
         BufferNotis[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
