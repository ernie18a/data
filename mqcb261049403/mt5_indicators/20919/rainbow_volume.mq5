//+------------------------------------------------------------------+
//|                                               Rainbow_Volume.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Rainbow Volume indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot VOL
#property indicator_label1  "VOL"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrDodgerBlue,clrRed,clrGold,clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod=10;   // Period
//--- indicator buffers
double         BufferVOL[];
double         BufferColors[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVOL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Rainbow Volume ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVOL,true);
   ArraySetAsSeries(BufferColors,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferVOL,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVOL[i]=(double)tick_volume[i];
      BufferColors[i]=
        (
      //--- рост цены и увеличение объёма
         close[i]>close[i+period] && tick_volume[i]>tick_volume[i+period] ? 0 :
      //--- рост цены и уменьшение объёмов
         close[i]>close[i+period] && tick_volume[i]<tick_volume[i+period] ? 1 :
      //--- падение цены и увеличение объёмов
         close[i]<close[i+period] && tick_volume[i]>tick_volume[i+period] ? 2 :
      //--- падение цены и уменьшение объёма
         close[i]<close[i+period] && tick_volume[i]<tick_volume[i+period] ? 3 : 4
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
