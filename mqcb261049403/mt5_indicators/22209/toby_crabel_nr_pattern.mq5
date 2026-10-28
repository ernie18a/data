//+------------------------------------------------------------------+
//|                                       Toby_Crabel_NR_Pattern.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Toby Crabel NR Pattern indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot WS
#property indicator_label1  "Wide Range Bar"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot NS
#property indicator_label2  "Narrow Range Bar"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums // 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable
enum ENUM_NR_METHOD
  {
   METHOD_2NR,       // 2NR
   METHOD_3NR,       // 3NR
   METHOD_4NR,       // 4NR
   METHOD_8NR,       // 8NR
   METHOD_CUSTOM     // Custom
  };
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_NR_METHOD    InpMethod      =  METHOD_2NR; // NR Method
input uint              InpSample      =  2;          // Sample (NR Custom)
input uint              InpPeriod      =  20;         // Period (NR Custom)
input ENUM_INPUT_YES_NO InpShowWide    =  INPUT_YES;  // Show wide range bar
input ENUM_INPUT_YES_NO InpShowNarrow  =  INPUT_YES;  // Show narrow range bar
input ENUM_INPUT_YES_NO InpExludeCurr  =  INPUT_YES;  // Exclude current bar
//--- indicator buffers
double         BufferWS[];
double         BufferNS[];
double         BufferHL[];
//--- global variables
int            sample;
int            period;
int            period_max;
int            shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   SetSP(InpMethod);
   period_max=fmax(sample,period);
   shift=(InpExludeCurr ? 1 : 0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferNS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHL,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Toby Crabel NR Pattern");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWS,true);
   ArraySetAsSeries(BufferNS,true);
   ArraySetAsSeries(BufferHL,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1-shift;
      ArrayInitialize(BufferWS,EMPTY_VALUE);
      ArrayInitialize(BufferNS,EMPTY_VALUE);
      ArrayInitialize(BufferHL,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(sample,i+shift);
      int bh=Highest(sample,i+shift);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         return 0;
      double min=low[bl];
      double max=high[bh];
      BufferHL[i+shift]=max-min;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferWS[i+shift]=BufferNS[i+shift]=EMPTY_VALUE;
      int bl=Lowest(period,i+shift);
      int bh=Highest(period,i+shift);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         return 0;
      double min=BufferHL[bl];
      double max=BufferHL[bh];
      if(InpShowWide)
         BufferWS[i+shift]=(max==BufferHL[i+shift] ? high[i+shift] : EMPTY_VALUE);
      if(InpShowNarrow)
         BufferNS[i+shift]=(min==BufferHL[i+shift] ? high[i+shift] : EMPTY_VALUE);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSP(ENUM_NR_METHOD method)
  {
   switch(method)
     {
      case METHOD_2NR :
        sample=2;
        period=20;
        break;
      case METHOD_3NR :
        sample=3;
        period=20;
        break;
      case METHOD_4NR :
        sample=4;
        period=40;
        break;
      case METHOD_8NR :
        sample=8;
        period=40;
        break;
      default:
        sample=(int)InpSample;
        period=(int)InpPeriod;
        break;
     }
  }  
//+------------------------------------------------------------------+
