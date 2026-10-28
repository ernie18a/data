//+------------------------------------------------------------------+
//|                                      Murreys_Math_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Murreys Math Oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MMO
#property indicator_label1  "Murreys Math"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLime,clrSpringGreen,clrLimeGreen,clrGreen,clrSaddleBrown,clrChocolate,clrTan,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  100;        // Period
input double            InpMultiplier  =  0.125;      // Multiplier
input ENUM_INPUT_YES_NO InpShowLevels  =  INPUT_YES;  // Show levels
//--- indicator buffers
double         BufferMMO[];
double         BufferColors[];
//--- global variables
double         multiplier;
double         level_2;
double         level_4;
double         level_6;
double         level_8;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   multiplier=(InpMultiplier<0 ? 0 : InpMultiplier);
   level_2=2*multiplier;
   level_4=4*multiplier;
   level_6=6*multiplier;
   level_8=8*multiplier;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMMO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Murreys Math oscillator ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,(InpShowLevels ? 8 : 0));
   if(InpShowLevels)
     {
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, level_8);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1, level_6);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2, level_4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,3, level_2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,4,-level_2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,5,-level_4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,6,-level_6);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,7,-level_8);
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMMO,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMMO,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period,i);
      int bh=Highest(period,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      double range=max-min;
      double mid=min+multiplier*range*4.0;

      BufferMMO[i]=(range!=0 ? 2.0*(close[i]-mid)/range : 0);
      
      if(BufferMMO[i]>0)
        {
         BufferColors[i]=0;
         if(BufferMMO[i]>=level_6)
            BufferColors[i]=3;
         else
           {
            if(BufferMMO[i]>=level_4)
               BufferColors[i]=2;
            else
              {
               if(BufferMMO[i]>=level_2)
                  BufferColors[i]=1;
              }
           }
        }
      else
        {
         BufferColors[i]=4;
         if(BufferMMO[i]<=-level_6)
            BufferColors[i]=7;
         else
           {
            if(BufferMMO[i]<=-level_4)
               BufferColors[i]=6;
            else
              {
               if(BufferMMO[i]<=-level_2)
                  BufferColors[i]=5;
              }
           }
        }
     }

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
