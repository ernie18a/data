//+------------------------------------------------------------------+
//|                                                Power_Measure.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Power measure oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot PM
#property indicator_label1  "PM"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  20;   // Period
//--- indicator buffers
double         BufferPM[];
double         BufferCC[];
double         BufferHL[];
//--- global variables
int            period_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferHL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Power measure ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPM,true);
   ArraySetAsSeries(BufferCC,true);
   ArraySetAsSeries(BufferHL,true);
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferPM,EMPTY_VALUE);
      ArrayInitialize(BufferCC,0);
      ArrayInitialize(BufferHL,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCC[i]=100.0*(close[i]-close[i+1])/(close[i+1]!=0 ? close[i+1] : 1.0);
      BufferHL[i]=100.0*(high[i]-low[i+1])/(low[i+1]!=0 ? low[i+1] : 1.0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ma_cc=GetSMA(rates_total,i,period_ma,BufferCC);
      double ma_hl=GetSMA(rates_total,i,period_ma,BufferHL);

      double sum=0,sum_cc2=0,sum_hl2=0;
      for(int j=0; j<period_ma; j++)
        {
         sum+=(BufferCC[i+j]-ma_cc)*(BufferHL[i+j]-ma_hl);
         sum_cc2+=(BufferCC[i+j]-ma_cc)*(BufferCC[i+j]-ma_cc);
         sum_hl2+=(BufferHL[i+j]-ma_hl)*(BufferHL[i+j]-ma_hl);
        }
      BufferPM[i]=(sum_cc2!=0 && sum_hl2!=0 ? sum/sqrt(sum_cc2*sum_hl2) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
