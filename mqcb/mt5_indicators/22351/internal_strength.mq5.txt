//+------------------------------------------------------------------+
//|                                            Internal_Strength.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Internal Strength oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Data
#property indicator_label1  "Internal Strength"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_CALC_MODE
  {
   MODE_HLC,   // HLC
   MODE_RSI    // RSI
  };
//--- input parameters
input ENUM_CALC_MODE InpMode        =  MODE_RSI;   // Calculating mode
input uint           InpPeriod      =  14;         // RSI period
input double         InpOverbought  =  55.0;       // Overbought
input double         InpOversold    =  45.0;       // Oversold
//--- indicator buffers
double         BufferData[];
double         BufferRAW[];
double         BufferPos[];
double         BufferNeg[];
//--- global variables
double         overbought;
double         oversold;
double         center;
int            period_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(InpOverbought<=50.0 ? 50.1 : InpOverbought);;
   oversold=(InpOversold>=overbought ? overbought-0.1 : InpOversold>=50.0 ? 49.9 : InpOversold);
   center=50.0;
   if(InpMode==MODE_HLC)
     {
      overbought/=100.0;
      oversold/=100.0;
      center/=100.0;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferData,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNeg,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Internal Strength ("+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,center);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferData,true);
   ArraySetAsSeries(BufferRAW,true);
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
   if(rates_total<fmax(period_rsi,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferData,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double hl=high[i]-low[i];
      BufferRAW[i]=(hl!=0 ? (close[i]-low[i])/hl : 0);
      if(InpMode==MODE_HLC)
         BufferData[i]=BufferRAW[i];
     }
   if(InpMode==MODE_RSI)
      return(RSIOnArray(rates_total,prev_calculated,0,period_rsi,BufferRAW,BufferPos,BufferNeg,BufferData));

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index on array                                 |
//+------------------------------------------------------------------+
template<typename T>
int RSIOnArray(const int rates_total,
               const int prev_calculated,
               const int begin,
               const int period,
               const T &price[],
               double &buffer_pos[],
               double &buffer_neg[],
               double &buffer_rsi[]
              )
  {
   int   i;
   T     diff;
//--- check for rates count
   if(period<1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_rsi=ArrayGetAsSeries(buffer_rsi);
   if(as_series_price)
      ArraySetAsSeries(price,false);
   if(as_series_rsi)
     {
      ArraySetAsSeries(buffer_rsi,false);
      ArraySetAsSeries(buffer_pos,false);
      ArraySetAsSeries(buffer_neg,false);
     }
//--- preliminary calculations
   int pos=prev_calculated-1;
   if(pos<=period)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      buffer_rsi[0]=0.0;
      buffer_pos[0]=0.0;
      buffer_neg[0]=0.0;
      T SumP=0.0;
      T SumN=0.0;
      for(i=1; i<=period; i++)
        {
         buffer_rsi[i]=0.0;
         buffer_pos[i]=0.0;
         buffer_neg[i]=0.0;
         diff=price[i]-price[i-1];
         SumP+=(diff>0 ? diff : 0);
         SumN+=(diff<0 ?-diff : 0);
        }
      //--- calculate first visible value
      buffer_pos[period]=double(SumP/period);
      buffer_neg[period]=double(SumN/period);
      
      buffer_rsi[period]=100.0-(100.0/(1.0+buffer_pos[period]/(buffer_neg[period]>0 ? buffer_neg[period] : DBL_MIN)));
      //--- prepare the position value for main calculation
      pos=period+1;
     }
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
      diff=price[i]-price[i-1];
      buffer_pos[i]=(buffer_pos[i-1]*(period-1)+(diff>0.0 ? diff : 0.0))/period;
      buffer_neg[i]=(buffer_neg[i-1]*(period-1)+(diff<0.0 ?-diff : 0.0))/period;
      buffer_rsi[i]=100.0-100.0/(1+buffer_pos[i]/(buffer_neg[i]>0 ? buffer_neg[i] : DBL_MIN));
     }
//--- restore as_series flags
   if(as_series_price) ArraySetAsSeries(price,true);
   if(as_series_rsi)
     {
      ArraySetAsSeries(buffer_rsi,true);
      ArraySetAsSeries(buffer_pos,true);
      ArraySetAsSeries(buffer_neg,true);
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
