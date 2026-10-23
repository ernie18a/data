//+------------------------------------------------------------------+
//|                                             RSI_With_Step_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI with step MA oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot RSI
#property indicator_label1  "SRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodRSI      =  14;            // RSI period
input int                  InpStep           =  5;             // Step
input uint                 InpPeriodMA       =  6;             // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // MA applied price
//--- indicator buffers
double         BufferRSI[];
double         BufferPos[];
double         BufferNeg[];
double         BufferMA[];
//--- global variables
int            period_rsi;
int            period_ma;
int            step;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   step=int(InpStep<1 ? 1 : InpStep);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferNeg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SRSI("+(string)period_rsi+","+(string)step+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,30);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,70);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferPos,true);
   ArraySetAsSeries(BufferNeg,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int beg=period_ma*2-2+step;
   if(limit>1)
     {
      limit=rates_total-beg-1;
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   double sump=0;
   double sumn=0;
   double positive=0;
   double negative=0;
   double diff=0;
   //---
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-beg-1)
        {
         sump=0;
         sumn=0;
         for(int j=i+period_ma-1; j>=i; j--)
           {
            diff=BufferMA[j]-(BufferMA[j+step]!=EMPTY_VALUE ? BufferMA[j+step] : 0);
            if(diff>=0)
               sump=sump+diff;
            else
               sumn=sumn-diff;
           }
         positive=sump/period_rsi;
         negative=sumn/period_rsi;
        }
      else
        {
         diff=BufferMA[i]-BufferMA[i+step];
         if(diff>=0)
            sump=diff;
         else
            sumn=-diff;
         positive=(BufferPos[i+1]*(period_rsi-1)+sump)/period_rsi;
         negative=(BufferNeg[i+1]*(period_rsi-1)+sumn)/period_rsi;
        }
      BufferPos[i]=positive;
      BufferNeg[i]=negative;
      BufferRSI[i]=(negative==0 ? 0 : 100.-(100./(1.+positive/negative)));
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
