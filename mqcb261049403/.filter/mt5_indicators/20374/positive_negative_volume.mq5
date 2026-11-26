//+------------------------------------------------------------------+
//|                                     Positive_Negative_Volume.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru"
#property version   "1.00"
#property description "Positive Negative Volume"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Hist
#property indicator_label1  "Volume"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_METHOD_CALC
  {
   METHOD_PR,  // Price
   METHOD_HA   // Heiken Ashi
  };
//--- input parameters
input ENUM_METHOD_CALC  InpMethod=METHOD_PR;  // Calculation method
//--- indicator buffers
double         BufferHist[];
double         BufferColors[];
double         BufferO[];
double         BufferC[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferC,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PNVol");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetString(0,PLOT_LABEL,"Volume("+(InpMethod==METHOD_HA ? "HAshi" : "Price")+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferO,true);
   ArraySetAsSeries(BufferC,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferO,0);
      ArrayInitialize(BufferC,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(InpMethod==METHOD_HA)
        {
         if(i==rates_total-2)
            BufferO[i]=(open[i+1]+close[i+1])/2;
         else
            BufferO[i]=(BufferO[i+1]+BufferC[i+1])/2;
         BufferC[i]=(open[i]+high[i]+low[i]+close[i])/4;
        }
      else
        {
         BufferO[i]=open[i];
         BufferC[i]=close[i];
        }
      if(BufferC[i]>BufferO[i])
        {
         BufferHist[i]=(double)tick_volume[i];
         BufferColors[i]=0;
        }
      else
        {
         BufferHist[i]=(double)-tick_volume[i];
         BufferColors[i]=1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
