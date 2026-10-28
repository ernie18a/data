//+------------------------------------------------------------------+
//|                                                    Ehlers_CG.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ehlers Center of Gravity indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot CG0
#property indicator_label1  "CoG Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot CG1
#property indicator_label2  "CoG Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod   =  10;   // Period
//--- indicator buffers
double         BufferCG0[];
double         BufferCG1[];
double         BufferPrice[];
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
   SetIndexBuffer(0,BufferCG0,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCG1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Ehler's Center of Gravity ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCG0,true);
   ArraySetAsSeries(BufferCG1,true);
   ArraySetAsSeries(BufferPrice,true);
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferCG0,EMPTY_VALUE);
      ArrayInitialize(BufferCG1,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
     }

//--- Расчёт индикатора
   double num=0,demon=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      num=demon=0;
      BufferPrice[i]=(high[i]+low[i])/2.0;
      for(int j=0; j<period-1; j++)
        {
         num+=(j+1)*BufferPrice[i+j];
         demon+=BufferPrice[i+j];
        }
      BufferCG0[i]=-num/demon+(period+1)/2.0;
      BufferCG1[i]=BufferCG0[i+1];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
