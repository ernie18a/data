//+------------------------------------------------------------------+
//|                                                          ASO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average Sentiment Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Bulls
#property indicator_label1  "Bulls"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bears
#property indicator_label2  "Bears"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_MODE
  {
   MODE_COMBINED,    // Combined
   MODE_INTRA_BAR,   // Intra-bar
   MODE_GROUP        // Group algorithm
  };
//--- input parameters
input uint           InpPeriodRange =  10;            // Range period
input uint           InpPeriodSm    =  10;            // Smoothing period
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;      // Method
input ENUM_MODE      InpMode        =  MODE_COMBINED; // Mode
//--- indicator buffers
double         BufferBulls[];
double         BufferBears[];
double         BufferBL[];
double         BufferBR[];
//--- global variables
int            period_range;
int            period_smooth;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_range=int(InpPeriodRange<1 ? 1 : InpPeriodRange);
   period_smooth=int(InpPeriodSm<2 ? 2 : InpPeriodSm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBulls,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBears,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferBR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ASO ("+(string)period_range+","+(string)period_smooth+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,100.0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBulls,true);
   ArraySetAsSeries(BufferBears,true);
   ArraySetAsSeries(BufferBL,true);
   ArraySetAsSeries(BufferBR,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_range-1;
      ArrayInitialize(BufferBulls,EMPTY_VALUE);
      ArrayInitialize(BufferBears,EMPTY_VALUE);
      ArrayInitialize(BufferBL,0);
      ArrayInitialize(BufferBR,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double intra_range=high[i]-low[i];
      if(intra_range==0) intra_range=1.0;
      //---
      int bl=LowestHigh(period_range,i);
      int bh=HighestLow(period_range,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double group_low=high[bl];
      double group_high=low[bh];
      double group_open=open[i+period_range];
      double group_range=group_high-group_low;
      if(group_range==0) group_range=1.0;


      double intra_bar_bulls=((((close[i]-low[i])+(high[i]-open[i]))/2.0)*100.0)/intra_range;
      double group_bulls=((((close[i]-group_low)+(group_high-group_open))/2.0)*100.0)/group_range;
      double intra_bar_bears=((((high[i]-close[i])+(open[i]-low[i]))/2.0)*100.0)/intra_range;
      double group_bears=((((group_high-close[i])+(group_open-group_low))/2.0)*100.0)/group_range;

      if(InpMode==MODE_COMBINED)
        {
         BufferBL[i]=(intra_bar_bulls+group_bulls)/2.0;
         BufferBR[i]=(intra_bar_bears+group_bears)/2.0;
        }
      else
        {
         if(InpMode==MODE_INTRA_BAR)
           {
            BufferBL[i]=intra_bar_bulls;
            BufferBR[i]=intra_bar_bears;
           }
         else
           {
            BufferBL[i]=group_bulls;
            BufferBR[i]=group_bears;
           }
        }
     }
//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBL,BufferBulls)==0)
            return 0;
         if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBR,BufferBears)==0)
            return 0;
        break;
      case MODE_SMMA :
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBL,BufferBulls)==0)
            return 0;
         if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBR,BufferBears)==0)
            return 0;
        break;
      case MODE_LWMA :
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBL,BufferBulls,weight_sum)==0)
            return 0;
         if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBR,BufferBears,weight_sum)==0)
            return 0;
        break;
      //---MODE_SMA
      default        :
         if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBL,BufferBulls)==0)
            return 0;
         if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_smooth,BufferBR,BufferBears)==0)
            return 0;
        break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Low           |
//+------------------------------------------------------------------+
int HighestLow(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии High           |
//+------------------------------------------------------------------+
int LowestHigh(const int count,const int start)

  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
