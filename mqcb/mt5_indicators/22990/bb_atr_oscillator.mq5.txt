//+------------------------------------------------------------------+
//|                                            BB_ATR_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "BB ATR oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot BBATR
#property indicator_label1  "BBands ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriodATR   =  14;   // ATR period
input double   InpMultiplier  =  2.0;  // ATR multiplier
input uint     InpPeriodBB    =  20;   // BB period
input double   InpDeviationBB =  2.0;  // BB deviation
//--- indicator buffers
double         BufferBBATR[];
double         BufferATR[];
double         BufferBBUP[];
double         BufferBBDN[];
//--- global variables
double         deviation;
double         multiplier;
int            period_atr;
int            period_bb;
int            period_max;
int            handle_atr;
int            handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   period_bb=int(InpPeriodBB<1 ? 1 : InpPeriodBB);
   period_max=fmax(period_atr,period_bb);
   deviation=InpDeviationBB;
   multiplier=InpMultiplier;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBBATR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferBBUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferBBDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BB ATR Osc ("+(string)period_atr+","+(string)multiplier+","+(string)period_bb+","+(string)deviation+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBBATR,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferBBUP,true);
   ArraySetAsSeries(BufferBBDN,true);
//--- create handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_bb=iBands(NULL,PERIOD_CURRENT,period_bb,0,deviation,PRICE_CLOSE);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_bb,") object was not created: Error ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferBBATR,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferBBUP,0);
      ArrayInitialize(BufferBBDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferBBUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferBBDN);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBBATR[i]=BufferBBUP[i]-BufferBBDN[i]-BufferATR[i]*multiplier;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
