//+------------------------------------------------------------------+
//|                                                 Breakout_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Breakout RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot BRSI
#property indicator_label1  "BRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  14;      // Period
input double   InpOverbought  =  80.0;    // Overbought
input double   InpOversold    =  20.0;    // Oversold
//--- indicator buffers
double         BufferBRSI[];
double         BufferBPower[];
double         BufferN[];
double         BufferP[];
//--- global variables
double         overbought;
double         oversold;
int            period_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriod<2 ? 2 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBPower,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Breakout RSI ("+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBRSI,true);
   ArraySetAsSeries(BufferBPower,true);
   ArraySetAsSeries(BufferN,true);
   ArraySetAsSeries(BufferP,true);
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
   if(rates_total<fmax(period_rsi,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferBRSI,EMPTY_VALUE);
      ArrayInitialize(BufferBPower,0);
      ArrayInitialize(BufferN,0);
      ArrayInitialize(BufferP,0);
     }
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double min=fmin(low[i],low[i+1]);
      double max=fmax(high[i],high[i+1]);

      double BPrice=(open[i+1]+max+min+close[i])/4.0;
      double BStrength=(max-min!=0 ? (close[i]-open[i+1])/(max-min) : 0);
      double BVolume=double(tick_volume[i]+tick_volume[i+1]);

      BufferBPower[i]=(BPrice*BStrength*BVolume)*Point();

      if(BufferBPower[i]>BufferBPower[i+1])
        {
         BufferP[i]=fabs(BufferBPower[i]);
         BufferN[i]=0;
        }
      else
        {
         BufferN[i]=fabs(BufferBPower[i]);
         BufferP[i]=0;
        }
      double avgN=GetSMA(rates_total,i,period_rsi,BufferN);
      double avgP=GetSMA(rates_total,i,period_rsi,BufferP);
      BufferBRSI[i]=(avgN!=0 ? 100.0-100.0/(1.0+avgP/avgN) : 0);
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
