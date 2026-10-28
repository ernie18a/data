//+------------------------------------------------------------------+
//|                                                         WRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wilder's RSI"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot WRSI
#property indicator_label1  "WRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrChocolate
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  70.0;          // Overbought
input double               InpOversold       =  30.0;          // Oversold
//--- indicator buffers
double         BufferWRSI[];
double         BufferMA[];
double         BufferPosRAW[];
double         BufferNegRAW[];
double         BufferPositive[];
double         BufferNegative[];
//--- global variables
double         overbought;
double         oversold;
double         k;
int            period_rsi;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriod<1 ? 1 : InpPeriod);
   k=1.0/period_rsi;
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPosRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNegRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferPositive,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferNegative,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wilder's RSI ("+(string)period_rsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,3,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWRSI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPosRAW,true);
   ArraySetAsSeries(BufferNegRAW,true);
   ArraySetAsSeries(BufferPositive,true);
   ArraySetAsSeries(BufferNegative,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_rsi,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_rsi-2;
      ArrayInitialize(BufferWRSI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferPosRAW,0);
      ArrayInitialize(BufferNegRAW,0);
      ArrayInitialize(BufferPositive,0);
      ArrayInitialize(BufferNegative,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=BufferMA[i]-BufferMA[i+1];

      BufferPosRAW[i]=BufferNegRAW[i]=0;
      if(diff>0)
         BufferPosRAW[i]=diff;
      else if(diff<0)
         BufferNegRAW[i]=-diff;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-period_rsi-2)
        {
         BufferPositive[i]=GetSMA(rates_total,i,period_rsi,BufferPosRAW);
         BufferNegative[i]=GetSMA(rates_total,i,period_rsi,BufferNegRAW);
        }
      else
        {
         BufferPositive[i]=k*(BufferPosRAW[i]-BufferPositive[i+1])+BufferPositive[i+1];
         BufferNegative[i]=k*(BufferNegRAW[i]-BufferNegative[i+1])+BufferNegative[i+1];
        }

      if(BufferNegative[i]!=0)
         BufferWRSI[i]=100.0-100.0/(1.0+BufferPositive[i]/BufferNegative[i]);
      else
        {
         if(BufferPositive[i]!=0)
            BufferWRSI[i]=100.0;
         else
            BufferWRSI[i]=50.0;
        }
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
