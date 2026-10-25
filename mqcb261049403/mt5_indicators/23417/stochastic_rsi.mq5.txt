//+------------------------------------------------------------------+
//|                                               Stochastic_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Stochastic RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot SK1
#property indicator_label1  "RSI Stoch %K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SD1
#property indicator_label2  "RSI Stoch %D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint              InpPeriodK     =  14;               // Stochastic %K period
input uint              InpPeriodD     =  3;                // Stochastic %D period
input uint              InpSlowing     =  5;                // Stochastic slowing
input uint              InpPeriodRSI   =  14;               // RSI period
input double            InpOverbought  =  80.0;             // Overbought
input double            InpOversold    =  20.0;             // Oversold
//--- indicator buffers
double         BufferSK[];
double         BufferSD[];
double         BufferRSI[];
double         BufferSKI[];
//--- global variables
double            overbought;
double            oversold;
int               periodRSI;
int               periodK;
int               periodD;
int               slowing;
int               period_max;
int               handle_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   periodRSI=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   periodK=int(InpPeriodK<1 ? 1 : InpPeriodK);
   periodD=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   period_max=fmax(periodD,fmax(periodK,slowing));
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSKI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic RSI("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSK,true);
   ArraySetAsSeries(BufferSD,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferSKI,true);
//--- create handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,periodRSI,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI("+(string)periodRSI+") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-periodK-1;
      ArrayInitialize(BufferSK,EMPTY_VALUE);
      ArrayInitialize(BufferSD,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferSKI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
 
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double min=DBL_MAX,max=0;
      for(int j=i; j<i+periodK; j++)
        {
         if(BufferRSI[j]>max) max = BufferRSI[j];
         if(BufferRSI[j]<min) min = BufferRSI[j];
        }
      BufferSKI[i]=(min!=max ? (BufferRSI[i]-min)/(max-min)*100.0 : 100.0);
     }
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSK[i]=SMA(rates_total,BufferSKI,slowing,i);
      BufferSD[i]=SMA(rates_total,BufferSK,periodD,i);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return array_src[shift];
   double sum=0;
   for(int i=0; i<period; i++)
      sum+=array_src[shift+i];
   return(sum/period);
  }
//+------------------------------------------------------------------+
