//+------------------------------------------------------------------+
//|                                                           TP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot TP
#property indicator_label1  "Trend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP
#property indicator_label2  "Up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "Down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod   =  14;         // Period
input ENUM_INPUT_YES_NO InpShowUpDn =  INPUT_NO;   // Show lines Up and Down
//--- indicator buffers
double         BufferTP[];
double         BufferUP[];
double         BufferDN[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDN,INDICATOR_DATA);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Advance Trend Pressure("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferUP,true);
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferTP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferUP,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double summ_up=0,summ_dn=0;
      for(int n=0; n<period; n++)
        {
         if(close[i+n]>open[i+n])
           {
            summ_up+=close[i+n]-open[i+n];
            summ_up+=open[i+n]-low[i+n];
            summ_dn+=high[i+n]-close[i+n];
           }
         else if(close[i+n]<open[i+n])
           {
            summ_dn+=open[i+n]-close[i+n];
            summ_dn+=high[i+n]-open[i+n];
            summ_up+=close[i+n]-low[i+n];
           }
        }
      if(InpShowUpDn)
        {
         BufferUP[i]=summ_up;
         BufferDN[i]=summ_dn;
        }
      else
         BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
      BufferTP[i]=summ_up-summ_dn;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
