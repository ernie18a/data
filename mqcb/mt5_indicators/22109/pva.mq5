//+------------------------------------------------------------------+
//|                                                          PVA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "SonicR PVA Volumes indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot PVA
#property indicator_label1  "PVA"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver,clrLightGreen,clrDeepPink,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriodClimax   =  10;   // Climax period
input uint     InpPeriodRising   =  10;   // Rising period
input double   InpFactorRising   =  1.0;  // Rising factor
input double   InpFactorExtreme  =  2.0;  // Extreme factor
//--- indicator buffers
double         BufferPVA[];
double         BufferColors[];
double         BufferRange[];
double         BufferMA[];
//--- global variables
double         factor_rs;
double         factor_ex;
int            period_cl;
int            period_rs;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cl=int(InpPeriodClimax<1 ? 1 : InpPeriodClimax);
   period_rs=int(InpPeriodRising<1 ? 1 : InpPeriodRising);
   period_max=fmax(period_cl,period_rs);
   factor_rs=InpFactorRising;
   factor_ex=InpFactorExtreme;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPVA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferRange,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SonicR PVA Volumes ("+(string)period_cl+","+(string)period_rs+","+DoubleToString(factor_rs,1)+","+DoubleToString(factor_ex,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPVA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferRange,true);
   ArraySetAsSeries(BufferMA,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferPVA,EMPTY_VALUE);
      ArrayInitialize(BufferRange,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPVA[i]=(double)tick_volume[i];
      BufferRange[i]=(high[i]-low[i])*tick_volume[i];
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=GetSMA(rates_total,i,period_rs,BufferPVA);
      int bh=ArrayMaximum(BufferRange,i+1,period_cl);
      if(bh==WRONG_VALUE)
         continue;
      double Max=BufferRange[bh];
      
      BufferColors[i]=0;
      if(BufferPVA[i]>=MA*factor_rs)
        {
         if(close[i]>open[i])
            BufferColors[i]=1;
         else
            BufferColors[i]=2;
        }
      if(BufferRange[i]>=Max || tick_volume[i]>=MA*factor_ex)
        {
         if(close[i]>open[i])
            BufferColors[i]=3;
         else
            BufferColors[i]=4;
        }
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
