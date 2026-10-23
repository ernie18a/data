//+------------------------------------------------------------------+
//|                                                ReverseMinMax.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Reverse Min Max indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot RevMin
#property indicator_label1  "Reverse Min"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot RevMax
#property indicator_label2  "Reverse Max"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Min
#property indicator_label3  "Min"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Max
#property indicator_label4  "Max"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodRev   =  5;          // Reverse period
input ENUM_INPUT_YES_NO InpShowMinMax  =  INPUT_NO;   // Show Min/Max lines
input uint              InpPeriodMM    =  20;         // Min/Max period
//--- indicator buffers
double         BufferRevMin[];
double         BufferRevMax[];
double         BufferMin[];
double         BufferMax[];
//--- global variables
int            period_mm;
int            period_rev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rev=int(InpPeriodRev<2 ? 2 : InpPeriodRev);
   period_mm=int(InpPeriodMM<2 ? 2 : InpPeriodMM);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRevMin,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRevMax,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMin,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMax,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Reverse Min Max ("+(string)period_rev+","+(string)period_mm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRevMin,true);
   ArraySetAsSeries(BufferRevMax,true);
   ArraySetAsSeries(BufferMin,true);
   ArraySetAsSeries(BufferMax,true);
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
      limit=rates_total-2;
      ArrayInitialize(BufferRevMin,EMPTY_VALUE);
      ArrayInitialize(BufferRevMax,EMPTY_VALUE);
      ArrayInitialize(BufferMin,EMPTY_VALUE);
      ArrayInitialize(BufferMax,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int highest_low=HighestLow(period_rev-1,i+1);
      int lowest_high=LowestHigh(period_rev-1,i+1);
      if(highest_low==WRONG_VALUE || lowest_high==WRONG_VALUE)
         continue;
      BufferRevMax[i]=high[lowest_high];
      BufferRevMin[i]=low[highest_low];
      if(InpShowMinMax)
        {
         int highest_high=HighestHigh(period_mm-1,i+1);
         int lowest_low=LowestLow(period_mm-1,i+1);
         if(highest_high==WRONG_VALUE || lowest_low==WRONG_VALUE)
            continue;
         BufferMax[i]=high[highest_high];
         BufferMin[i]=low[lowest_low];
        }
      else
        {
         BufferMax[i]=EMPTY_VALUE;
         BufferMin[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int HighestHigh(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Low           |
//+------------------------------------------------------------------+
int HighestLow(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии High           |
//+------------------------------------------------------------------+
int LowestHigh(const int count,const int start)

  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int LowestLow(const int count,const int start)

  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
