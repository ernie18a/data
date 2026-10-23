//+------------------------------------------------------------------+
//|                                                 Glitch_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot GI
#property indicator_label1  "GI"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrMediumSpringGreen,clrOrangeRed,clrLightSalmon
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriodMA       =  30;            // MA Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
input uint                 InpPeriodROC      =  1;             // ROC Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferGI[];
double         BufferColors[];
double         BufferMA1[];
double         BufferMAP[];
//--- global variables
int            period_ma;
int            period_roc;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_roc=int(InpPeriodROC<1 ? 1 : InpPeriodROC);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferGI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Glitch Index("+(string)period_ma+","+(string)period_roc+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferGI,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
//--- create handle MA
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
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
   if(limit>1)
     {
      limit=rates_total-period_roc-1;
      ArrayInitialize(BufferGI,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Pr=BufferMA1[i];
      double MA=BufferMAP[i];
      double MA_ROC=BufferMAP[i+period_roc];
      double rocsma=((MA-MA_ROC)*0.1)+1.0;
      double smamult=MA*rocsma;
      double diff=Pr-smamult;
      
      BufferGI[i]=100.*diff/Pr;
      BufferColors[i]=(BufferGI[i]<0 ? (BufferGI[i+1]<BufferGI[i] ? 3 : 2) : (BufferGI[i+1]<BufferGI[i] ? 0 : 1));
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
