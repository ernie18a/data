//+------------------------------------------------------------------+
//|                                       InvestorsVsSpeculators.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Investors vs Speculators indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Delta
#property indicator_label1  "Inv vs Spec"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1
//--- enums
enum ENUM_CALC_MODE
  {
   MODE_CS,  // Classical MT
   MODE_TS   // Trade Station
  };
//--- input parameters
input uint           InpPeriod   =  14;      // Period
input ENUM_CALC_MODE InpMethod   =  MODE_CS; // AD method
//--- indicator buffers
double         BufferDelta[];
double         BufferSpeculators[];
double         BufferInvestors[];
double         BufferVol[];
//--- global variables
int            period_ind;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDelta,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSpeculators,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferInvestors,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Investors Vs Speculators ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDelta,true);
   ArraySetAsSeries(BufferSpeculators,true);
   ArraySetAsSeries(BufferInvestors,true);
   ArraySetAsSeries(BufferVol,true);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ind,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDelta,EMPTY_VALUE);
      ArrayInitialize(BufferSpeculators,0);
      ArrayInitialize(BufferInvestors,0);
      ArrayInitialize(BufferVol,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AD=
        (
         high[i]-low[i]==0 ? 0 :
         InpMethod==MODE_CS ? ((close[i]-low[i])-(high[i]-close[i]))/(high[i]-low[i])*tick_volume[i] :
         (close[i]-open[i])/(high[i]-low[i])*tick_volume[i]
        );
      BufferVol[i]=(double)tick_volume[i];
      double AVG=GetSMA(rates_total,i,period_ind,BufferVol);

      if(tick_volume[i]>AVG)
        {
         BufferSpeculators[i]=BufferSpeculators[i+1];
         BufferInvestors[i]=BufferInvestors[i+1]+AD;
        }
      else
        {
         BufferInvestors[i]=BufferInvestors[i+1];
         BufferSpeculators[i]=BufferSpeculators[i+1]+AD;
        }
      BufferDelta[i]=BufferInvestors[i]-BufferSpeculators[i];
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
