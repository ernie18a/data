//+------------------------------------------------------------------+
//|                                                  Lindas_Coil.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Linda's Coil indicator"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot LC
#property indicator_label1  "LC"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_PATT_METHOD
  {
   METHOD_EN,        // Engulfed
   METHOD_EQ         // Engulfed or Equal
  };
enum ENUM_PATT_TYPE
  {
   TYPE_PREV,        // Previous
   TYPE_FIRST        // First
  };
//--- input parameters
input uint              InpPeriod   =  3;          // Period
input ENUM_PATT_METHOD  InpMethod   =  METHOD_EN;  // Method
input ENUM_PATT_TYPE    InpType     =  TYPE_FIRST; // Type
//--- indicator buffers
double         BufferLC[];
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
   SetIndexBuffer(0,BufferLC,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,118);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Linda's Coil ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLC,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferLC,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int beg=i+period-1;
      bool flag=true;
      for(int j=beg-1; j>=i; j--)
        {
         if(InpType==TYPE_PREV)
           {
            if((((high[j]>=high[j+1]) || (low[j]<=low[j+1])) && InpMethod==METHOD_EQ) || (((high[j]>high[j+1]) || (low[j]<low[j+1])) && InpMethod==METHOD_EN))
               flag=false;
           }
         else
           {
            if((((high[j]>=high[beg]) || (low[j]<=low[beg])) && InpMethod==METHOD_EQ) || (((high[j]>high[beg]) || (low[j]<low[beg])) && InpMethod==METHOD_EN))
               flag=false;
           }
        }
      BufferLC[i]=(flag ? low[i] : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
