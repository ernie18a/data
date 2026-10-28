//+------------------------------------------------------------------+
//|                                          Ultimate_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ultimate Oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot UO
#property indicator_label1  "Ultimate Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod1     =  7;    // First momentum period
input uint     InpPeriod2     =  14;   // Second momentum period
input uint     InpPeriod3     =  28;   // Third momentum period
input double   InpOverbought  =  70.0; // Overbought
input double   InpOversold    =  30.0; // Oversold
//--- indicator buffers
double         BufferUO[];
double         BufferBP[];
double         BufferTR[];
//--- global variables
double         overbought;
double         oversold;
int            period_1;
int            period_2;
int            period_3;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   period_max=fmax(period_1,fmax(period_2,period_3));
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold>=overbought ? overbought-0.1 : InpOversold<0 ? 0 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Ultimate Oscillator ("+(string)period_1+","+(string)period_2+","+(string)period_3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUO,true);
   ArraySetAsSeries(BufferBP,true);
   ArraySetAsSeries(BufferTR,true);
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferUO,EMPTY_VALUE);
      ArrayInitialize(BufferBP,0);
      ArrayInitialize(BufferTR,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBP[i]=close[i]-fmin(low[i],close[i+1]);
      BufferTR[i]=fmax(high[i],close[i+1])-fmin(low[i],close[i+1]);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double bp_sum1=0;
      double tr_sum1=0;
      double bp_sum2=0;
      double tr_sum2=0;
      double bp_sum3=0;
      double tr_sum3=0;

      for(int j=(i+period_1-1); j>=i; j--)
        {
         bp_sum1+=BufferBP[j];
         tr_sum1+=BufferTR[j];
        }
      double avg1=(tr_sum1!=0 ? bp_sum1/tr_sum1 : 0);

      for(int j=(i+period_2-1); j>=i; j--)
        {
         bp_sum2+=BufferBP[j];
         tr_sum2+=+BufferTR[j];
        }
      double avg2=(tr_sum2!=0 ? bp_sum2/tr_sum2 : 0);

      for(int j=(i+period_3-1); j>=i; j--)
        {
         bp_sum3+=BufferBP[j];
         tr_sum3+=BufferTR[j];
        }
      double avg3=(tr_sum3!=0 ? bp_sum3/tr_sum3 : 0);

      BufferUO[i]=100.0*((4.0*avg1)+(2.0*avg2)+avg3)/7.0;//(4+2+1)
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
