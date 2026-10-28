//+------------------------------------------------------------------+
//|                                                        VolMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot VolMA
#property indicator_label1  "VolMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int                  InpRSIVolPeriod   =  20;            // RSI Vol Period
input int                  InpMAPeriod       =  50;            // MA Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Calculated method
input ENUM_APPLIED_PRICE   InpPrice          =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferVolMA[];
double         BufferRSIOnArray[];
double         BufferRSIPositive[];
double         BufferRSINegative[];
//--- global variables
int            rsi_vol_period;
int            ma_period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVolMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRSIOnArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRSIPositive,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRSINegative,INDICATOR_CALCULATIONS);
//--- set indicators short name
   IndicatorSetString(INDICATOR_SHORTNAME,"VolMA");
//--- set global variables
   rsi_vol_period=(InpRSIVolPeriod<1 ? 1 : InpRSIVolPeriod);
   ma_period=(InpMAPeriod<1 ? 1 : InpMAPeriod);
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
   if(rates_total<fmax(rsi_vol_period,ma_period)) return 0;
//--- Set arrays as time series
   ArraySetAsSeries(BufferVolMA,true);
   ArraySetAsSeries(BufferRSIOnArray,true);
   ArraySetAsSeries(BufferRSIPositive,true);
   ArraySetAsSeries(BufferRSINegative,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-fmax(rsi_vol_period,ma_period)-1;
      ArrayInitialize(BufferVolMA,EMPTY_VALUE);
      ArrayInitialize(BufferRSIOnArray,EMPTY_VALUE);
      ArrayInitialize(BufferRSIPositive,EMPTY_VALUE);
      ArrayInitialize(BufferRSINegative,EMPTY_VALUE);
     }
//--- Расчёт RSI на данных тиковых объёмов
   RSIOnArray(rates_total,prev_calculated,0,rsi_vol_period,tick_volume,BufferRSIPositive,BufferRSINegative,BufferRSIOnArray);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double PeriodMA=BufferRSIOnArray[i]*ma_period/100;
      PeriodMA=fmax(PeriodMA,1);
      double ma=GetMA((int)PeriodMA,InpMethod,InpPrice,i);
      if(ma==WRONG_VALUE) return 0;
      BufferVolMA[i]=ma;
     }
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
               double &buffer_rsi[])
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
//| MA one from one specified bar                                    |
//+------------------------------------------------------------------+
double GetMA(const int period,
             const ENUM_MA_METHOD method,
             const ENUM_APPLIED_PRICE price,
             const int shift)
  {
   double array[];
   int handle=iMA(NULL,PERIOD_CURRENT,period,0,method,price);
   ResetLastError();
   if(handle==INVALID_HANDLE)
     {
      Print("Error creating MA handle ",GetLastError());
      return(WRONG_VALUE);
     }
   if(CopyBuffer(handle,0,shift,1,array)==1) return array[0];
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
