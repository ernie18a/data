//+------------------------------------------------------------------+
//|                                                      DPO_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Detrended Price Oscillator Bar"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMediumSeaGreen,clrOrange,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  14;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
double         BufferColors[];
double         BufferOpenMA[];
double         BufferHighMA[];
double         BufferLowMA[];
double         BufferCloseMA[];
//--- global variables
int            period;
int            handle_ma_o;
int            handle_ma_h;
int            handle_ma_l;
int            handle_ma_c;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferOpenMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferHighMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLowMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferCloseMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"DPO Bar("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferOpenMA,true);
   ArraySetAsSeries(BufferHighMA,true);
   ArraySetAsSeries(BufferLowMA,true);
   ArraySetAsSeries(BufferCloseMA,true);
//--- create MA`s handle
   ResetLastError();
   handle_ma_o=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_OPEN);
   if(handle_ma_o==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_OPEN object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma_h=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_HIGH);
   if(handle_ma_h==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma_l=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_LOW);
   if(handle_ma_l==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma_c=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_CLOSE);
   if(handle_ma_c==INVALID_HANDLE)
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferOpen,EMPTY_VALUE);
      ArrayInitialize(BufferHigh,EMPTY_VALUE);
      ArrayInitialize(BufferLow,EMPTY_VALUE);
      ArrayInitialize(BufferClose,EMPTY_VALUE);
      ArrayInitialize(BufferOpenMA,EMPTY_VALUE);
      ArrayInitialize(BufferHighMA,EMPTY_VALUE);
      ArrayInitialize(BufferLowMA,EMPTY_VALUE);
      ArrayInitialize(BufferCloseMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma_o,0,0,count,BufferOpenMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma_h,0,0,count,BufferHighMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma_l,0,0,count,BufferLowMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma_c,0,0,count,BufferCloseMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferOpen[i]=open[i]-BufferOpenMA[i];
      BufferHigh[i]=high[i]-BufferHighMA[i];
      BufferLow[i]=low[i]-BufferLowMA[i];
      BufferClose[i]=close[i]-BufferCloseMA[i];
      BufferColors[i]=(BufferClose[i]>BufferOpen[i] ? 0 : BufferClose[i]<BufferOpen[i] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
