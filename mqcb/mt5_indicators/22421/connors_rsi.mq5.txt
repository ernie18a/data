//+------------------------------------------------------------------+
//|                                                  Connors_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Larry Connors RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot CRSI
#property indicator_label1  "CRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodRSI         =  3;             // RSI period
input uint                 InpPeriodSM          =  2;             // Pulse RCI period
input uint                 InpPeriodPercRank    =  100;           // Percent rank period
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_CLOSE;   // Applied price
input double               InpOverbought        =  80.0;          // Overbought
input double               InpOversold          =  20.0;          // Oversold
//--- indicator buffers
double         BufferCRSI[];
double         BufferUpDown[];
double         BufferRSI[];
double         BufferRSI2[];
double         BufferArrRSI[];
double         BufferMA[];
double         BufferPosRSI[];
double         BufferNegRSI[];
//--- global variables
double         overbought;
double         oversold;
int            period_rsi;
int            period_sm;
int            period_rnk;
int            period_max;
int            handle_rsi;
int            handle_rsi2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   period_sm=int(InpPeriodSM<2 ? 2 : InpPeriodSM);
   period_rnk=int(InpPeriodPercRank<1 ? 1 : InpPeriodPercRank);
   period_max=fmax(period_sm,period_rnk);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUpDown,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRSI2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferArrRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferPosRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferNegRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Connors RSI ("+(string)period_rsi+","+(string)period_sm+","+(string)period_rnk+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCRSI,true);
   ArraySetAsSeries(BufferUpDown,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferRSI2,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferArrRSI,true);
   ArraySetAsSeries(BufferPosRSI,true);
   ArraySetAsSeries(BufferNegRSI,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi2=iRSI(NULL,PERIOD_CURRENT,2,InpAppliedPrice);
   if(handle_rsi2==INVALID_HANDLE)
     {
      Print("The iRSI(2) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferCRSI,EMPTY_VALUE);
      ArrayInitialize(BufferUpDown,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferRSI2,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferArrRSI,0);
      ArrayInitialize(BufferPosRSI,0);
      ArrayInitialize(BufferNegRSI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_rsi2,0,0,count,BufferRSI2);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUpDown[i]=
        (
         BufferMA[i]>BufferMA[i+1] ? (BufferUpDown[i+1]>0 ? BufferUpDown[i+1]+1 : 1) :
         BufferMA[i]<BufferMA[i+1] ? (BufferUpDown[i+1]<0 ? BufferUpDown[i+1]-1 :-1) : 0
        );
     }
   if(RSIOnArray(rates_total,prev_calculated,0,period_sm,BufferUpDown,BufferPosRSI,BufferNegRSI,BufferArrRSI)==0)
      return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double RSI1=BufferRSI[i];
      double RSI2=BufferArrRSI[i];
      double RSI3=PercentRank(i);
      BufferCRSI[i]=(RSI1+RSI2+RSI3)/3.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| PercentRank                                                      |
//+------------------------------------------------------------------+
double PercentRank(int index)
  {
   double count=0;
   for(int i=1; i<=period_rnk; i++)
      if(BufferRSI2[index]>BufferRSI2[index+i])
         count++;
   return 100.0*count/(double)period_rnk;
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
