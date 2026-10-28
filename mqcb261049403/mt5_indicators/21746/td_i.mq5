//+------------------------------------------------------------------+
//|                                                         TD_I.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Modified Thomas DeMark Indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot TDI
#property indicator_label1  "TDI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  8;    // Period
input uint     InpShift       =  1;    // Shift
input double   InpOverbought  =  70;   // Overbought
input double   InpOversold    =  30;   // Oversold
//--- indicator buffers
double         BufferTDI[];
double         BufferHighDiff[];
double         BufferLowDiff[];
//--- global variables
double         overbought;
double         oversold;
int            period_ind;
int            shift;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   shift=int(InpShift<1 ? 1 : InpShift);
   period_max=fmax(period_ind,shift);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTDI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHighDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferLowDiff,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TD I("+(string)period_ind+","+(string)shift+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"TD I("+(string)period_ind+","+(string)shift+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTDI,true);
   ArraySetAsSeries(BufferHighDiff,true);
   ArraySetAsSeries(BufferLowDiff,true);
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
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferTDI,EMPTY_VALUE);
      ArrayInitialize(BufferHighDiff,0);
      ArrayInitialize(BufferLowDiff,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHighDiff[i]=fmax(0,high[i]-high[i+shift]);
      BufferLowDiff[i]=fmax(0,low[i+shift]-low[i]);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double HighAvg=GetSMA(rates_total,i,period_ind,BufferHighDiff);
      double LowAvg=GetSMA(rates_total,i,period_ind,BufferLowDiff);
      BufferTDI[i]=(HighAvg+LowAvg!=0 ? 100.0*HighAvg/(HighAvg+LowAvg) : 0);
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
