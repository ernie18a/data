//+------------------------------------------------------------------+
//|                                                         SRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slow Relative Strength Index oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot SRSI
#property indicator_label1  "SRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  8;             // Period
input uint                 InpPeriodSm       =  5;             // Smoothing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpMiddle         =  50.0;          // Middle level
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferSRSI[];
double         BufferNetChgAvg[];
double         BufferTotChgAvg[];
double         BufferEMA[];
//--- global variables
double         overbought;
double         middle;
double         oversold;
double         sf;
int            period;
int            period_ema;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   period_ema=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   sf=1.0/(double)period;
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.2 ? 0.2 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.2 : InpOversold);
   middle=(InpMiddle<=oversold ? oversold+0.1 : InpOversold>=overbought ? overbought-0.1 : InpMiddle);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferNetChgAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTotChgAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferEMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SRSI ("+(string)period+","+(string)period_ema+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,middle);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSRSI,true);
   ArraySetAsSeries(BufferNetChgAvg,true);
   ArraySetAsSeries(BufferTotChgAvg,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ema,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ema,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferSRSI,EMPTY_VALUE);
      ArrayInitialize(BufferNetChgAvg,0);
      ArrayInitialize(BufferTotChgAvg,0);
      ArrayInitialize(BufferEMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferEMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferNetChgAvg[i]=(BufferEMA[i]-BufferEMA[i+1])*sf;
         BufferTotChgAvg[i]=fabs(BufferEMA[i]-BufferEMA[i+1]);
        }
      else
        {
         double Change=BufferEMA[i]-BufferEMA[i+1];
         BufferNetChgAvg[i]=BufferNetChgAvg[i+1]+sf*(Change-BufferNetChgAvg[i+1]);
         BufferTotChgAvg[i]=BufferTotChgAvg[i+1]+sf*(fabs(Change)-BufferTotChgAvg[i+1]);
         double ChgRatio=(BufferTotChgAvg[i]!=0 ? BufferNetChgAvg[i]/BufferTotChgAvg[i] : 0);
         BufferSRSI[i]=50.0*(1.0+ChgRatio);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
