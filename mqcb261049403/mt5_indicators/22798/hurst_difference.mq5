//+------------------------------------------------------------------+
//|                                             Hurst_Difference.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Hurst Difference oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Hurst
#property indicator_label1  "Hurst difference"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  30;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferHurst[];
double         BufferPrice[];
double         BufferFDI[];
//--- global variables
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHurst,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferFDI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Hurst Difference ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHurst,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferFDI,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferHurst,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferFDI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   double max=0,min=DBL_MAX;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      for(int j=(i+period-1); j>=i; j--)
        {
         if(j==(i+period-1))
            max=min=BufferPrice[j];
         else
           {
            if(BufferPrice[j]>max) max=BufferPrice[j];
            if(BufferPrice[j]<min) min=BufferPrice[j];
           }
        }
      double priorDiff=0, length=0;
      for(int j=(i+period-1); j>=i; j--)
        {
         if((max-min)>0)
           {
            double diff=(BufferPrice[j]-min)/(max-min);
            if(max>min)
               length+=sqrt(pow(diff-priorDiff,2)+(1.0/pow(period,2)));
            priorDiff=diff;
           }
        }
      BufferFDI[i]=(length>0 ? (1.0+(log(length)+log(2)))/log(2*(period-1)) : 0);
      BufferHurst[i]=BufferFDI[i+1]-BufferFDI[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
