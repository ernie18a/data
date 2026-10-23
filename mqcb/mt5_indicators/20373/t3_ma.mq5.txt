//+------------------------------------------------------------------+
//|                                                        T3_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Tim Tillson's T3 MA"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot T3MA
#property indicator_label1  "T3MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input double               InpCoeffB         =  0.88;          // Coefficient
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferT3MA[];
double         BufferMA[];
double         BufferE1[];
double         BufferE2[];
double         BufferE3[];
double         BufferE4[];
double         BufferE5[];
double         BufferE6[];
//--- global variables
int            period;
int            handle_ma;
double         c1,c2,c3,c4,w1,w2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   double b2,b3;
   b2=InpCoeffB*InpCoeffB;
   b3=b2*InpCoeffB;
   w1=4.0/(3.0+period);
   w2=1.0-w1;
   c1=-b3;
   c2=3*(b2+b3);
   c3=-3*(2*b2+InpCoeffB+b3);
   c4=1+3*InpCoeffB+b3+3*b2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferT3MA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferE1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferE2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferE3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferE4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferE5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferE6,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"T3MA("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferT3MA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferE1,true);
   ArraySetAsSeries(BufferE2,true);
   ArraySetAsSeries(BufferE3,true);
   ArraySetAsSeries(BufferE4,true);
   ArraySetAsSeries(BufferE5,true);
   ArraySetAsSeries(BufferE6,true);
//--- create MA's handle
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferT3MA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferE1,0);
      ArrayInitialize(BufferE2,0);
      ArrayInitialize(BufferE3,0);
      ArrayInitialize(BufferE4,0);
      ArrayInitialize(BufferE5,0);
      ArrayInitialize(BufferE6,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferE1[i]=w1*BufferMA[i]+w2*BufferE1[i+1];
      BufferE2[i]=w1*BufferE1[i]+w2*BufferE2[i+1];
      BufferE3[i]=w1*BufferE2[i]+w2*BufferE3[i+1];
      BufferE4[i]=w1*BufferE3[i]+w2*BufferE4[i+1];
      BufferE5[i]=w1*BufferE4[i]+w2*BufferE5[i+1];
      BufferE6[i]=w1*BufferE5[i]+w2*BufferE6[i+1];
      BufferT3MA[i]=c1*BufferE6[i]+c2*BufferE5[i]+c3*BufferE4[i]+c4*BufferE3[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
