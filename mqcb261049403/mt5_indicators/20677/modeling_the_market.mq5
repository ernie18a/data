//+------------------------------------------------------------------+
//|                                          Modeling_The_Market.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Modeling the market indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot MM
#property indicator_label1  "MMarket"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMM[];
double         BufferMA1[];
double         BufferMAP[];
double         BufferHP[];
double         BufferSlope[];
//--- global variables
double   alpha;
int      period;
int      handle_ma1;
int      handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<2 ? 2 : InpPeriod);
   alpha=(1.0-sin(2.0*M_PI/(double)period))/cos(2.0*M_PI/(double)period);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferHP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSlope,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MMarket("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMM,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferHP,true);
   ArraySetAsSeries(BufferSlope,true);
//--- create MA's handle
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period-4;
      ArrayInitialize(BufferMM,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferHP,0);
      ArrayInitialize(BufferSlope,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSlope[i]=BufferMA1[i]-BufferMA1[i+period-1];
      BufferHP[i]=0.5*(1.0+alpha)*(BufferMA1[i]-BufferMA1[i+1])+alpha*BufferHP[i+1];
      double SmoothSlope=(BufferSlope[i]+2.0*BufferSlope[i+1]+2.0*BufferSlope[i+2]+BufferSlope[i+3])/6.0;
      double IT=BufferMAP[i]+SmoothSlope/2.0;
      double CC=(BufferHP[i]+2.0*BufferHP[i+1]+2.0*BufferHP[i+2]+BufferHP[i+3])/6.0;
      BufferMM[i]=IT+CC;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
