//+------------------------------------------------------------------+
//|                                                         Pain.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Pain oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Pain
#property indicator_label1  "Pain"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  10;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferPain[];
double         BufferMAOpen[];
double         BufferMAHigh[];
double         BufferMALow[];
double         BufferMAClose[];
//--- global variables
int            period;
int            handle_mao;
int            handle_mah;
int            handle_mal;
int            handle_mac;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPain,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMALow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAClose,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Pain ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPain,true);
   ArraySetAsSeries(BufferMAOpen,true);
   ArraySetAsSeries(BufferMAHigh,true);
   ArraySetAsSeries(BufferMALow,true);
   ArraySetAsSeries(BufferMAClose,true);
//--- create MA's handles
   ResetLastError();
   handle_mao=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_OPEN);
   if(handle_mao==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_OPEN object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferPain,EMPTY_VALUE);
      ArrayInitialize(BufferMAOpen,0);
      ArrayInitialize(BufferMAHigh,0);
      ArrayInitialize(BufferMALow,0);
      ArrayInitialize(BufferMAClose,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mao,0,0,count,BufferMAOpen);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAHigh);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMALow);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mac,0,0,count,BufferMAClose);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferPain[i]=(3.0*BufferMAClose[i]-BufferMAOpen[i]-BufferMAHigh[i]-BufferMALow[i])/2.0;

      //--- return value of prev_calculated for next call
      return(rates_total);
  }
//+------------------------------------------------------------------+
