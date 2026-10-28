//+------------------------------------------------------------------+
//|                                                    IdeaTrend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Idea Trend oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Trend
#property indicator_label1  "Trend"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint           InpPeriod   =  20;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
input double         InpLevel    =  1.0;        // Threshold
//--- indicator buffers
double         BufferTrend[];
double         BufferColors[];
double         BufferMAH[];
double         BufferMAL[];
double         BufferMAC[];
//--- global variables
int            period;
int            handle_mah;
int            handle_mal;
int            handle_mac;
double         level;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   level=InpLevel;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTrend,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAC,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Idea Trend ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Direction trend threshold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferMAC,true);
//--- create MA's handles
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mac=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_CLOSE);
   if(handle_mac==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_CLOSE object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTrend,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
      ArrayInitialize(BufferMAC,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mac,0,0,count,BufferMAC);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MAH=BufferMAH[i];
      double MAL=BufferMAL[i];
      double MAC=BufferMAC[i];
      BufferTrend[i]=(MAC!=MAL ? (MAH-MAC)/(MAC-MAL) : 0);
      BufferColors[i]=(BufferTrend[i]<level ? 0 : BufferTrend[i]>level ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
