//+------------------------------------------------------------------+
//|                                                Dynamic_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Dynamic Trend indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Line
#property indicator_label1  "Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrBlue,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP
#property indicator_label2  "UP"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "DN"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
input uint     InpPercent  =  10;   // Percent
//--- indicator buffers
double         BufferLine[];
double         BufferColors[];
double         BufferUP[];
double         BufferDN[];
//--- global variables
int            percent;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   percent=(int)InpPercent;
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLine,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   PlotIndexSetInteger(2,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Dynamic Trend ("+(string)period+","+(string)percent+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLine,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-4;
      ArrayInitialize(BufferLine,0);
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      BufferLine[limit]=close[limit];
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=HighestClose(period,i+1);
      int bl=LowestClose(period,i+1);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      
      BufferColors[i]=2;
      if(close[i]<BufferLine[i+1])
        {
         BufferLine[i]=close[bh]-percent*Point();
         BufferColors[i]=1;
        }
      else
        {
         BufferLine[i]=close[bl]+percent*Point();
         BufferColors[i]=0;
        }
      
      BufferUP[i]=BufferDN[i]=EMPTY_VALUE;

      if(close[i+3]>BufferLine[i+2] && close[i+2]<BufferLine[i+3])
         BufferUP[i]=open[i];

      if(close[i+2]<BufferLine[i+1] && close[i+2]>BufferLine[i+3])
         BufferDN[i]=open[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int HighestClose(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int LowestClose(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
