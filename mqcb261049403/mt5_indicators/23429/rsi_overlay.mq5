//+------------------------------------------------------------------+
//|                                                  RSI_Overlay.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI Overlay indicator."
#property description "Colored bars depending on RSI Oscillator."
#property description "    Available modes:"
#property description "1) RSI above or below 50 Line"
#property description "2) Compare Current RSI value with Previous RSI value"
#property description "3) RSI Above Overbought or Below Oversold"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrForestGreen,clrMediumAquamarine,clrRed,clrBurlyWood,clrLightGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_METHOD_OVERLAY
  {
   METHOD_OVL_50,       // RSI vs level 50
   METHOD_OVL_OBOS,     // RSI vs OB/OS levels
   METHOD_OVL_VALUES    // Current and previous RSI values
  };
//---
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH,
   CANDLE_TYPE_BEARISH,
   CANDLE_TYPE_NEUTRAL,
  };
//--- input parameters
input ENUM_METHOD_OVERLAY  InpMethodOvl      =  METHOD_OVL_50; // Data RSI Compare mode
input uint                 InpPeriod         =  14;            // RSI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // RSI applied price
input double               InpOverbought     =  70.0;          // RSI overbought
input double               InpOversold       =  30.0;          // RSI oversold
//--- indicator buffers
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferRSI[];
//--- global variables
double         overbought;
double         oversold;
int            period;
int            handle_rsi;
bool           prev_fgnd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
   prev_fgnd=ChartGetInteger(0,CHART_FOREGROUND);
   ChartSetInteger(0,CHART_FOREGROUND,false);
   ChartRedraw();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferRSI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI Overlay ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferRSI,true);
//--- create handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
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
      ArrayInitialize(BufferRSI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
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
      InpMethodOvl==METHOD_OVL_OBOS ? 
      (BufferRSI[shift]>overbought ? CANDLE_TYPE_BULLISH : BufferRSI[shift]<oversold ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL) :
      InpMethodOvl==METHOD_OVL_VALUES ?
      (BufferRSI[shift]>BufferRSI[shift+1] ? CANDLE_TYPE_BULLISH : BufferRSI[shift]<BufferRSI[shift+1] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL) :
      (BufferRSI[shift]>50 ? CANDLE_TYPE_BULLISH : BufferRSI[shift]<50 ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL)
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
