//+------------------------------------------------------------------+
//|                                            Internal_Strength.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Internal Strength indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot IS
#property indicator_label1  "IS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCornflowerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_MODE
  {
   MODE_RAW,                     // Price
   MODE_RSI                      // RSI on price
  };
//---
enum ENUM_TYPE
  {
   TYPE_LINE   =  DRAW_LINE,     // Line
   TYPE_BAR    =  DRAW_HISTOGRAM // Bars
  };
//--- input parameters
input uint        InpPeriodRSI   =  14;         // RSI period
input ENUM_MODE   InpCalcMode    =  MODE_RSI;   // Calculating method
input ENUM_TYPE   InpDrawType    =  TYPE_LINE;  // Drawing type
//--- indicator buffers
double         BufferIS[];
double         BufferRAW[];
double         BufferPosRSI[];
double         BufferNegRSI[];
//--- global variables
int            period_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPosRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNegRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Internal Strength ("+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpDrawType);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIS,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferPosRSI,true);
   ArraySetAsSeries(BufferNegRSI,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferIS,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferPosRSI,0);
      ArrayInitialize(BufferNegRSI,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=(high[i]!=low[i] ? (close[i]-low[i])/(high[i]-low[i]) : 0);
     }
     
//--- Расчёт индикатора
   if(InpCalcMode==MODE_RAW)
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferIS[i]=BufferRAW[i];
   else
      return RSIOnArray(rates_total,prev_calculated,0,period_rsi,BufferRAW,BufferPosRSI,BufferNegRSI,BufferIS);
   
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
