//+------------------------------------------------------------------+
//|                                                    Slingshot.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slingshot oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot Hist
#property indicator_label1  "SValue"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLimeGreen,clrRed,clrOrange,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod            =  14;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice      =  PRICE_CLOSE;   // Applied price
input uint                 InpPeriodSig         =  14;            // Signal period
input ENUM_APPLIED_PRICE   InpAppliedPriceSig   =  PRICE_LOW;     // Signal price
//--- indicator buffers
double         BufferHist[];
double         BufferColors[];
double         BufferSignal[];
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
int            period;
int            period_sig;
int            period_max;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
   period_max=fmax(period,period_sig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Slingshot oscillator ("+(string)period+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPriceSig);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The Signal`s iMA(1) object was not created: Error ",GetLastError());
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
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA10=BufferMA1[i];
      double MA11=BufferMA1[i+period];
      double MA20=BufferMA2[i];
      double MA21=BufferMA2[i+period_sig];

      BufferHist[i]=MA10-MA11;
      BufferSignal[i]=MA20-MA21;
      //---
      BufferColors[i]=4;
      if(BufferHist[i]>0)
        {
         if(BufferHist[i]>BufferSignal[i])
            BufferColors[i]=(BufferHist[i]>BufferHist[i+1] ? 0 : 1);
         else
            BufferColors[i]=(BufferHist[i]<BufferHist[i+1] ? 3 : 4);
        }
      //---
      else
        {
         if(BufferHist[i]<BufferSignal[i])
            BufferColors[i]=(BufferHist[i]<BufferHist[i+1] ? 2 : 3);
         else
            BufferColors[i]=(BufferHist[i]>BufferHist[i+1] ? 1 : 4);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
