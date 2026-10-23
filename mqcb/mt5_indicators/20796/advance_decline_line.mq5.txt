//+------------------------------------------------------------------+
//|                                         Advance_Decline_Line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Advance Decline Line"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot ADL
#property indicator_label1  "ADL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  10;         // Period
input ENUM_INPUT_YES_NO InpCumulative  =  INPUT_YES;  // Use Cumulative mode
//--- indicator buffers
double         BufferADL[];
//--- global variables
int   period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferADL,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADL("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferADL,true);
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
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferADL,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-period-2)
         BufferADL[i]=0.;
      else
        {
         int rs=0,fs=0;
         for(int j=0; j<period; j++)
           {
            if(close[i+j]>open[i+j])
               rs++;
            else if(close[i+j]<open[i+j])
               fs++;
            BufferADL[i]=(InpCumulative ? rs-fs+BufferADL[i+1] : rs-fs);
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
