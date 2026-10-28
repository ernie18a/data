//+------------------------------------------------------------------+
//|                                                         SVSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slow Volume Strength Index oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot SVSI
#property indicator_label1  "SVSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodMA    =  6;       // EMA period
input uint     InpPeriodSm    =  14;      // Smoothing
input double   InpOverbought  =  80.0;    // Overbought
input double   InpMiddle      =  50.0;    // Middle
input double   InpOversold    =  20.0;    // Oversold
//--- indicator buffers
double         BufferSVSI[];
double         BufferPos[];
double         BufferNeg[];
double         BufferMA[];
//--- global variables
double         overbought;
double         middle;
double         oversold;
int            period_ma;
int            period_sm;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   middle=(InpMiddle>99.9 ? 99.9 : InpMiddle<0.1 ? 0.1 : InpMiddle);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<=middle ? middle+0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=middle ? middle-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSVSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferNeg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Slow Volume Strength Index ("+(string)period_ma+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,middle);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSVSI,true);
   ArraySetAsSeries(BufferPos,true);
   ArraySetAsSeries(BufferNeg,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sm-1;
      ArrayInitialize(BufferSVSI,EMPTY_VALUE);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(close[i]>BufferMA[i])
        {
         BufferPos[i]=tick_volume[i]/1000000.0;
         BufferNeg[i]=0.0;
        }
      else if(close[i]<BufferMA[i])
        {
         BufferNeg[i]=tick_volume[i]/1000000.0;
         BufferPos[i]=0.0;
        }
      else
         BufferPos[i]=BufferNeg[i]=0;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double AvgPosVol=GetSMA(rates_total,i,period_sm,BufferPos);
      double AvgNegVol=GetSMA(rates_total,i,period_sm,BufferNeg);
      double svs=(AvgNegVol!=0 ? AvgPosVol/AvgNegVol : 100.0);
      BufferSVSI[i]=100.0-100.0/(1.0+svs);
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
