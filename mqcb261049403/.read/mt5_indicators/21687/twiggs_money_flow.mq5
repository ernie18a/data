//+------------------------------------------------------------------+
//|                                            Twiggs_Money_Flow.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Twiggs Money Flow oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot TMF
#property indicator_label1  "TMF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod=21;   // Period
//--- indicator buffers
double         BufferTMF[];
double         BufferADV[];
double         BufferVol[];
double         BufferWMA_ADV[];
double         BufferWMA_V[];
//--- global variables
int            period_tmf;
double         k;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tmf=int(InpPeriod<1 ? 1 : InpPeriod);
   k=1.0/period_tmf;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTMF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferADV,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferWMA_ADV,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferWMA_V,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Twiggs Money Flow ("+(string)period_tmf+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_tmf);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTMF,true);
   ArraySetAsSeries(BufferADV,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferWMA_ADV,true);
   ArraySetAsSeries(BufferWMA_V,true);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_tmf,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTMF,EMPTY_VALUE);
      ArrayInitialize(BufferADV,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferWMA_ADV,0);
      ArrayInitialize(BufferWMA_V,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double TRH=fmax(high[i],close[i+1]);
      double TRL=fmin(low[i],close[i+1]);
      double TR=TRH-TRL;
      BufferADV[i]=(TR!=0 ? tick_volume[i]*(2.0*close[i]-TRL-TRH)/TR : 0);
      BufferVol[i]=(double)tick_volume[i];
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferWMA_ADV[i]=GetSMA(rates_total,i,period_tmf,BufferADV);
         BufferWMA_V[i]=GetSMA(rates_total,i,period_tmf,BufferVol);
        }
      else
        {
         BufferWMA_ADV[i]=(BufferADV[i]-BufferWMA_ADV[i+1])*k+BufferWMA_ADV[i+1];
         BufferWMA_V[i]=(BufferVol[i]-BufferWMA_V[i+1])*k+BufferWMA_V[i+1];
        }

      BufferTMF[i]=(BufferWMA_V[i]!=0 ? BufferWMA_ADV[i]/(BufferWMA_V[i]*Point()) : 0);
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
