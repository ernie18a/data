//+------------------------------------------------------------------+
//|                                                           CI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Congestion Identifier indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot CI
#property indicator_label1  "Counter graph"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot INC
#property indicator_label2  "Out"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DEC
#property indicator_label3  "In"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  28;      // Period
input double   InpDelta    =  100.0;   // Delta
input uint     InpLevel    =  14;      // Level
//--- indicator buffers
double         BufferCI[];
double         BufferINC[];
double         BufferDEC[];
//--- global variables
int            period;
int            level;
double         delta;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   level=int(InpLevel<1 ? 1 : InpLevel);
   delta=(InpDelta<1 ? 1 : InpDelta)*Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferINC,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDEC,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Congestion Identifier ("+(string)period+","+DoubleToString(level,1)+","+DoubleToString(delta,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,level);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCI,true);
   ArraySetAsSeries(BufferINC,true);
   ArraySetAsSeries(BufferDEC,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferCI,EMPTY_VALUE);
      ArrayInitialize(BufferINC,EMPTY_VALUE);
      ArrayInitialize(BufferDEC,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {   
      double top=close[i]+delta;
      double bottom=close[i]-delta;
      int count=0;
      for(int j=0; j<period; j++)
         if(close[i+j]<top && close[i+j]>bottom)
            count++;
      BufferCI[i]=count;
      BufferINC[i]=(BufferCI[i+1]<level && BufferCI[i]>level ? level : EMPTY_VALUE);
      BufferDEC[i]=(BufferCI[i+1]>level && BufferCI[i]<level ? level : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
