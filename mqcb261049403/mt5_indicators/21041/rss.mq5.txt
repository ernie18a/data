//+------------------------------------------------------------------+
//|                                                          RSS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Relative Spread Strength indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot RSS
#property indicator_label1  "RSS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSlateGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodFastMA   =  10;            // Fast EMA period
input uint                 InpPeriodSlowMA   =  50;            // Slow EMA period
input uint                 InpPeriodRSI      =  5;             // RSI period
input uint                 InpPeriodSm       =  5;             // Smoothing period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  70.0;          // Overbought level
input double               InpOversold       =  30.0;          // Oversold level
//--- indicator buffers
double         BufferRSS[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferRSI[];
double         BufferSpread[];
double         BufferPos[];
double         BufferNeg[];
//--- global variables
double         overbought;
double         oversold;
int            period_fma;
int            period_sma;
int            period_rsi;
int            period_sm;
int            weight_sum;
int            handle_fma;
int            handle_sma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA==period_fma ? period_fma+1 : InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_sm=int(InpPeriodSm<2 ? 2 : InpPeriodSm);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSpread,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferNeg,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Relative Spread Strength ("+(string)period_fma+","+(string)period_sma+","+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSS,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferSpread,true);
   ArraySetAsSeries(BufferPos,true);
   ArraySetAsSeries(BufferNeg,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,MODE_EMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,MODE_EMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRSS,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferSpread,0);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferSpread[i]=BufferFMA[i]-BufferSMA[i];
   RSIOnArray(rates_total,prev_calculated,0,period_rsi,BufferSpread,BufferPos,BufferNeg,BufferRSI);

//--- Расчёт индикатора
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferRSI,BufferRSS)==0)
      return 0;
   
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
