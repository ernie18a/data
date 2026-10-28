//+------------------------------------------------------------------+
//|                                                          PMF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot PMF
#property indicator_label1  "PMF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_ON_OFF
  {
   INPUT_ON    =  1, // On
   INPUT_OFF   =  0  // Off
  };
//--- input parameters
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_INPUT_ON_OFF    InpCumulative     =  INPUT_ON;      // Cumulative
//--- indicator buffers
double         BufferPMF[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables

//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPMF,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PMF");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPMF,true);
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
   if(rates_total<3) return 0;
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
      limit=rates_total-3;
      ArrayInitialize(BufferPMF,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(limit==rates_total-3) BufferPMF[i]=0;
      double Current=ValueByPrice(InpAppliedPrice,i,open,high,low,close);
      double Previous=ValueByPrice(InpAppliedPrice,i+1,open,high,low,close);
      double PrePrevious=ValueByPrice(InpAppliedPrice,i+2,open,high,low,close);
      double DiffCurrent=(Current-Previous)*tick_volume[i];
      double DiffPrevious=(Previous-PrePrevious)*tick_volume[i+1];
      if(InpCumulative)
         BufferPMF[i]=BufferPMF[i+1]+DiffCurrent;
      else
         BufferPMF[i]=DiffCurrent+DiffPrevious;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает расчётную цену                                        |
//+------------------------------------------------------------------+
double ValueByPrice(const ENUM_APPLIED_PRICE price,const int index,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   return
     (
      price==PRICE_CLOSE   ?  close[index]   :
      price==PRICE_OPEN    ?  open[index]    :
      price==PRICE_HIGH    ?  high[index]    :
      price==PRICE_LOW     ?  low[index]     :
      price==PRICE_MEDIAN  ?  (high[index]+low[index])/2.0              :
      price==PRICE_TYPICAL ?  (high[index]+low[index]+close[index])/3.0 :
      (high[index]+low[index]+2*close[index])/4.0
     );
  }
//+------------------------------------------------------------------+
