//+------------------------------------------------------------------+
//|                                                         WPVH.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wyckoff PV Histogram oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Fast
#property indicator_label1  "Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Slow
#property indicator_label2  "Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Hist"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrCornflowerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodFast     =  5;          // Fast period
input uint              InpPeriodSlow     =  15;         // Slow period
input ENUM_INPUT_YES_NO InpShowHistogram  =  INPUT_NO;   // Show histogram
//--- indicator buffers
double         BufferFast[];
double         BufferSlow[];
double         BufferHist[];
double         BufferRAW[];
//--- global variables
int            period_fast;
int            period_slow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFast,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSlow,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WPVH ("+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   if(InpShowHistogram)
     {
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
      PlotIndexSetInteger(2,PLOT_SHOW_DATA,true);
     }
   else
     {
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFast,true);
   ArraySetAsSeries(BufferSlow,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferRAW,true);
//---
   ChartRedraw();
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferFast,EMPTY_VALUE);
      ArrayInitialize(BufferSlow,EMPTY_VALUE);
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool UDPC=(close[i]>=((high[i]-low[i])/2.0+low[i]) && close[i]>close[i+1] ? true : false);
      bool UDNC=(close[i]<((high[i]-low[i])/2.0+low[i])  && close[i]>close[i+1] ? true : false);
      bool DDPC=(close[i]>=((high[i]-low[i])/2.0+low[i]) && close[i]<close[i+1] ? true : false);
      bool DDNC=(close[i]<((high[i]-low[i])/2.0+low[i])  && close[i]<close[i+1] ? true : false);
      bool HVWS=((high[i]-low[i])>=(high[i+1]-low[i+1])  && tick_volume[i]>tick_volume[i+1] ? true : false);
      bool HVNS=((high[i]-low[i])<(high[i+1]-low[i+1])   && tick_volume[i]>tick_volume[i+1] ? true : false);
      bool LVWS=((high[i]-low[i])>=(high[i+1]-low[i+1])  && tick_volume[i]<tick_volume[i+1] ? true : false);
      bool LVNS=((high[i]-low[i])<(high[i+1]-low[i+1])   && tick_volume[i]<tick_volume[i+1] ? true : false);

      BufferRAW[i]=
        (
         UDPC && LVWS ? 8 :
         UDPC && HVWS ? 7 :
         UDPC && HVNS ? 6 :
         UDPC && LVNS ? 5 :
         UDNC && LVWS ? 4 :
         UDNC && HVWS ? 3 :
         UDNC && HVNS ? 2 :
         UDNC && LVNS ? 1 :
         DDPC && LVNS ?-1 :
         DDPC && HVNS ?-2 :
         DDPC && HVWS ?-3 :
         DDPC && LVWS ?-4 :
         DDNC && LVNS ?-5 :
         DDNC && HVNS ?-6 :
         DDNC && HVWS ?-7 :
         DDNC && LVWS ?-8 : 0
        );
//--- Расчёт индикатора
      BufferSlow[i]=GetSMA(rates_total,i,period_slow,BufferRAW);
      BufferFast[i]=GetSMA(rates_total,i,period_fast,BufferRAW);
      BufferHist[i]=(!InpShowHistogram ? EMPTY_VALUE : BufferRAW[i]-BufferRAW[i+1]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+