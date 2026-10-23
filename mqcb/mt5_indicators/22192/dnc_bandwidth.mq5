//+------------------------------------------------------------------+
//|                                                DNC_Bandwidth.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Donchian Channel Bandwidth indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Width
#property indicator_label1  "DNC Band Width"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod         =  20;         // Period
input ENUM_INPUT_YES_NO InpCurrentPeriod  =  INPUT_YES;  // Analyze current bar
input ENUM_INPUT_YES_NO InpInPoints       =  INPUT_NO;   // Data in points
//--- indicator buffers
double         BufferWidth[];
double         BufferTop[];
double         BufferBottom[];
//--- global variables
double         size;
int            period;
int            shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   shift=(InpCurrentPeriod ? 0 : 1);
   size=Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWidth,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferBottom,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Donchian Channel Bandwidth ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWidth,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
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
   if(rates_total<fmax(period,4) || size==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferWidth,EMPTY_VALUE);
      ArrayInitialize(BufferTop,0);
      ArrayInitialize(BufferBottom,0);
     }
     
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=Highest(period,i+shift);
      int bl=Lowest(period,i+shift);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      BufferTop[i]=high[bh];
      BufferBottom[i]=low[bl];
     }
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferWidth[i]=(InpInPoints ? (BufferTop[i]-BufferBottom[i])/size : BufferTop[i]-BufferBottom[i]);

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
