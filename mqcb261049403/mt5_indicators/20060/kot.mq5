//+------------------------------------------------------------------+
//|                                                          KOT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property description   "Indicator Keep On Trading"
//--- plot KOT
#property indicator_label1  "KOT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint           InpPeriodATR   =  10;         // ATR period
input uint           InpPeriodMA    =  3;          // MA period
input ENUM_MA_METHOD InpMethod      =  MODE_LWMA;  // MA method
input double         InpMultiplier  =  0.1;        // Multiplier
//--- indicator buffers
double         BufferKOT[];
double         BufferMAH[];
double         BufferMAL[];
double         BufferATR[];
//--- global variables
int            period_ma;
int            period_atr;
int            handle_mah;
int            handle_mal;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferKOT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"KOT");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferKOT,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handle MA High
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") on PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create handle MA Low
   ResetLastError();
   handle_mal=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") on PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create handle ATR
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   int max=fmax(period_atr,period_ma);
   if(rates_total<max+2) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-3;
      ArrayInitialize(BufferKOT,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,EMPTY_VALUE);
      ArrayInitialize(BufferMAL,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int flag=0;
      BufferKOT[i]=EMPTY_VALUE;
      if(close[i]<low[i+1] && close[i]<low[i+2])
         BufferKOT[i]=BufferMAH[i]+InpMultiplier*BufferATR[i];
      if(close[i]>high[i+1] && close[i]>high[i+2])
         BufferKOT[i]=BufferMAL[i]-InpMultiplier*BufferATR[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
