//+------------------------------------------------------------------+
//|                Sylvain_Vervoort_RSI_inverse_fisher_transform.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Sylvain Vervoort RSI inverse fisher transform oscillator"
#property indicator_separate_window
#property indicator_buffers 18
#property indicator_plots   1
//--- plot SVRSIIFT
#property indicator_label1  "SVRSI InvFT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSlateBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodSVRMA =  2;       // SVRMA period
input uint     InpPeriodRSI   =  4;       // RSI period
input uint     InpPeriodMA    =  4;       // MA period
input double   InpOverbought  =  88.0;    // Overbought
input double   InpOversold    =  12.0;    // Oversold
//--- indicator buffers
double         BufferSVRSI[];
//---
double         BufferLWMA1[];
double         BufferLWMA2[];
double         BufferLWMA3[];
double         BufferLWMA4[];
double         BufferLWMA5[];
double         BufferLWMA6[];
double         BufferLWMA7[];
double         BufferLWMA8[];
double         BufferLWMA9[];
double         BufferLWMA10[];
double         BufferRMA[];
//---
double         BufferSmMA1[];
double         BufferSmMA2[];
//---
double         BufferRSI[];
double         BufferTmpRSI[];
double         BufferPosRSI[];
double         BufferNegRSI[];
//--- global variables
double         overbought;
double         oversold;
int            period_svrma;
int            period_rsi;
int            period_ma;
int            period_max;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_svrma=int(InpPeriodSVRMA<1 ? 1 : InpPeriodSVRMA);
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_max=period_svrma+period_svrma*9;
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSVRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLWMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferLWMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLWMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLWMA4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferLWMA5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferLWMA6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLWMA7,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferLWMA8,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferLWMA9,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferLWMA10,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferRMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferSmMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferSmMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferTmpRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferPosRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,BufferNegRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Sylvain Vervoort RSI inverse fisher transform ("+(string)period_svrma+","+(string)period_rsi+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSVRSI,true);
   ArraySetAsSeries(BufferLWMA1,true);
   ArraySetAsSeries(BufferLWMA2,true);
   ArraySetAsSeries(BufferLWMA3,true);
   ArraySetAsSeries(BufferLWMA4,true);
   ArraySetAsSeries(BufferLWMA5,true);
   ArraySetAsSeries(BufferLWMA6,true);
   ArraySetAsSeries(BufferLWMA7,true);
   ArraySetAsSeries(BufferLWMA8,true);
   ArraySetAsSeries(BufferLWMA9,true);
   ArraySetAsSeries(BufferLWMA10,true);
   ArraySetAsSeries(BufferRMA,true);
   ArraySetAsSeries(BufferSmMA1,true);
   ArraySetAsSeries(BufferSmMA2,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferTmpRSI,true);
   ArraySetAsSeries(BufferPosRSI,true);
   ArraySetAsSeries(BufferNegRSI,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_svrma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_svrma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSVRSI,EMPTY_VALUE);
      ArrayInitialize(BufferLWMA1,0);
      ArrayInitialize(BufferLWMA2,0);
      ArrayInitialize(BufferLWMA3,0);
      ArrayInitialize(BufferLWMA4,0);
      ArrayInitialize(BufferLWMA5,0);
      ArrayInitialize(BufferLWMA6,0);
      ArrayInitialize(BufferLWMA7,0);
      ArrayInitialize(BufferLWMA8,0);
      ArrayInitialize(BufferLWMA9,0);
      ArrayInitialize(BufferLWMA10,0);
      ArrayInitialize(BufferRMA,0);
      ArrayInitialize(BufferSmMA1,0);
      ArrayInitialize(BufferSmMA2,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferTmpRSI,0);
      ArrayInitialize(BufferPosRSI,0);
      ArrayInitialize(BufferNegRSI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferLWMA1);
   if(copied!=count) return 0;
   
//--- Расчёт SVRMA
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLWMA2[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA1);
      BufferLWMA3[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA2);
      BufferLWMA4[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA3);
      BufferLWMA5[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA4);
      BufferLWMA6[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA5);
      BufferLWMA7[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA6);
      BufferLWMA8[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA7);
      BufferLWMA9[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA8);
      BufferLWMA10[i]=LinearWeightedMA(rates_total,period_svrma,i,BufferLWMA9);
      double value=0;
      value+=5*BufferLWMA1[i];
      value+=4*BufferLWMA2[i];
      value+=3*BufferLWMA3[i];
      value+=2*BufferLWMA4[i];
      value+=BufferLWMA5[i];
      value+=BufferLWMA6[i];
      value+=BufferLWMA7[i];
      value+=BufferLWMA8[i];
      value+=BufferLWMA9[i];
      value+=BufferLWMA10[i];
      BufferRMA[i]=value/20.0;
     }
      
//--- Расчёт индикатора
   if(RSIOnArray(rates_total,prev_calculated,period_max,period_rsi,BufferRMA,BufferPosRSI,BufferNegRSI,BufferTmpRSI)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRSI[i]=0.1*(BufferTmpRSI[i]-50.0);
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferRSI,BufferSmMA1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferSmMA1,BufferSmMA2)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double zl_ema=BufferSmMA1[i]+(BufferSmMA1[i]-BufferSmMA2[i]);
      BufferSVRSI[i]=((pow(2.71828183,2*zl_ema)-1.0)/(pow(2.71828183,2*zl_ema)+1.0)+1.0)*50.0;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
double LinearWeightedMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0,count=0,total=0,k=0;
   int    wsum=0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   for(int j=index+period-1; j>=index; j--)
     {
      count++;
      k+=count;
      total+=price[j]*count;
     }
   result=total/k;
//---
   return(result);
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
      buffer_rsi[period]=100.0-(100.0/(1.0+buffer_pos[period]/(buffer_neg[period]>0 ? buffer_neg[period]: DBL_MIN)));
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
      //Print("buffer_pos[",i,"]=",DoubleToString(buffer_pos[i]),", buffer_neg[",i,"]=",DoubleToString(buffer_neg[i]));
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
