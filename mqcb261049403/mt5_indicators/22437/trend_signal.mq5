//+------------------------------------------------------------------+
//|                                                 Trend_Signal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Signal indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Dn
#property indicator_label1  "Bearish signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Up
#property indicator_label2  "Bullish signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- input parameters
input uint     InpPeriod   =  9;    // Period
input uint     InpRisk     =  30;   // Risk
//--- indicator buffers
double         BufferUp[];
double         BufferDn[];
double         BufferTrend[];
//--- global variables
int            period;
int            risk;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   risk=int(InpRisk<1 ? 1 : InpRisk);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDn,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUp,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTrend,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Signal ("+(string)period+","+(string)risk+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUp,true);
   ArraySetAsSeries(BufferDn,true);
   ArraySetAsSeries(BufferTrend,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferUp,EMPTY_VALUE);
      ArrayInitialize(BufferDn,EMPTY_VALUE);
      ArrayInitialize(BufferTrend,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      
      int bh=Highest(period,i+1);
      int bl=Lowest(period,i+1);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=high[bh];
      double min=low[bl];
      double Max=max-(max-min)*risk/100.0;
      double Min=min+(max-min)*risk/100.0;

      BufferDn[i]=BufferUp[i]=EMPTY_VALUE;
      if(close[i+1]<Max && close[i]>Max && BufferTrend[i+1]!=1.)
        {
         BufferTrend[i]=1;
         BufferUp[i]=open[i];
        }
      else
        {
         if(close[i+1]>Min && close[i]<Min && BufferTrend[i+1]!=-1.)
           {
            BufferTrend[i]=-1;
            BufferDn[i]=open[i];
           }
         else
            BufferTrend[i]=BufferTrend[i+1];
        }
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
