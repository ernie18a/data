//+------------------------------------------------------------------+
//|                                                 MACD_Overlay.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MACD Overlay indicator."
#property description "Colored bars depending on MACD Oscillator."
#property description "    Available modes:"
#property description "1) Compare MACD and Signal Lines"
#property description "2) MACD above or below Zero Line"
#property description "3) Compare Current MACD value with Previous MACD value"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrForestGreen,clrMediumAquamarine,clrRed,clrBurlyWood,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_METHOD_OVERLAY
  {
   METHOD_OVL_SIGNAL,   // MACD and signal Lines
   METHOD_OVL_ZERO,     // MACD vs zero line
   METHOD_OVL_VALUES    // Current and previous MACD values
  };
//---
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH,
   CANDLE_TYPE_BEARISH,
   CANDLE_TYPE_NEUTRAL,
  };
//--- input parameters
input ENUM_METHOD_OVERLAY  InpMethodOvl      =  METHOD_OVL_SIGNAL;   // Data MACD Compare mode
input uint                 InpPeriodFast     =  12;                  // MACD fast EMA period
input uint                 InpPeriodSlow     =  26;                  // MACD slow EMA period
input uint                 InpPeriodSignal   =  9;                   // MACD period signal line
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;         // MACD applied price
//--- indicator buffers
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferMACD[];
double         BufferSignal[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_signal;
int            period_max;
int            handle_macd;
bool           prev_fgnd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_signal=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
   period_max=fmax(period_signal,fmax(period_fast,period_slow));
   prev_fgnd=ChartGetInteger(0,CHART_FOREGROUND);
   ChartSetInteger(0,CHART_FOREGROUND,false);
   ChartRedraw();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferMACD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSignal,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD Overlay ("+(string)period_fast+","+(string)period_slow+","+(string)period_signal+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
//--- create handles
   ResetLastError();
   handle_macd=iMACD(NULL,PERIOD_CURRENT,period_fast,period_slow,period_signal,InpAppliedPrice);
   if(handle_macd==INVALID_HANDLE)
     {
      Print("The iMACD(",(string)period_fast,",",(string)period_slow,",",(string)period_signal,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0,CHART_FOREGROUND,prev_fgnd);
   ChartRedraw();
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
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferSignal,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_macd,MAIN_LINE,0,count,BufferMACD);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_macd,SIGNAL_LINE,0,count,BufferSignal);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCandleOpen[i]=open[i];
      BufferCandleHigh[i]=high[i];
      BufferCandleLow[i]=low[i];
      BufferCandleClose[i]=close[i];
      ENUM_CANDLE_TYPE type=CandleType(i,open,close);
      ENUM_CANDLE_TYPE overlay=CandleTypeOverlay(i);
      BufferColors[i]=
        (
         overlay==CANDLE_TYPE_BULLISH ?
         (type==CANDLE_TYPE_BULLISH ? 0 : type==CANDLE_TYPE_BEARISH ? 1 : 4) :
         overlay==CANDLE_TYPE_BEARISH ?
         (type==CANDLE_TYPE_BEARISH ? 2 : type==CANDLE_TYPE_BULLISH ? 3 : 4) : 4
        );
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает тип рисуемой свечи                                    |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CandleTypeOverlay(const int shift)
  {
   return
     (
      InpMethodOvl==METHOD_OVL_SIGNAL ? 
      (BufferMACD[shift]>BufferSignal[shift] ? CANDLE_TYPE_BULLISH : BufferMACD[shift]<BufferSignal[shift] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL) :
      InpMethodOvl==METHOD_OVL_VALUES ?
      (BufferMACD[shift]>BufferMACD[shift+1] ? CANDLE_TYPE_BULLISH : BufferMACD[shift]<BufferMACD[shift+1] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL) :
      (BufferMACD[shift]>0 ? CANDLE_TYPE_BULLISH : BufferMACD[shift]<0 ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает тип свечи                                             |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CandleType(const int shift,const double &open[],const double &close[])
  {
   return(open[shift]<close[shift] ? CANDLE_TYPE_BULLISH : open[shift]>close[shift] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL);
  }
//+------------------------------------------------------------------+
