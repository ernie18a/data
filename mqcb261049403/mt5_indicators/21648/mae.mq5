//+------------------------------------------------------------------+
//|                                                          MAE.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Moving Average Envelopes Percentage (MAE%)"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot MAE
#property indicator_label1  "MAE"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input double               InpOffset         =  0.5;           // Deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  100.0;         // Overbought
input double               InpOversold       =  0.0;           // Oversold
//--- indicator buffers
double         BufferMAE[];
double         BufferMAP[];
double         BufferMA1[];
//--- global variables
double         overbought;
double         oversold;
double         deviation;
int            period;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=(InpOffset==0 ? 0.01 : InpOffset);
   overbought=(InpOverbought<50.01 ? 50.01 : InpOverbought);
   oversold=(InpOversold>49.99 ? 49.99 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMAE,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MAE% ("+(string)period+","+DoubleToString(deviation,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMAE,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMA1,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
      limit=rates_total-1;
      ArrayInitialize(BufferMAE,EMPTY_VALUE);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMA1,0);
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
      double up=BufferMAP[i]*(1.0+deviation/100.0);
      double dn=BufferMAP[i]*(1.0-deviation/100.0);
      BufferMAE[i]=(up!=dn ? 100.0*(BufferMA1[i]-dn)/(up-dn) : 50.0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
