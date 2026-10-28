//+------------------------------------------------------------------+
//|                                 Specified_Time_Range_Candles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Specified time range candles indicator"
#property description "Colored candles depending on specific time range."
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrSeaGreen,clrOrangeRed,clrDimGray,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH,
   CANDLE_TYPE_BEARISH,
   CANDLE_TYPE_NEUTRAL,
   CANDLE_TYPE_NONE
  };
//--- input parameters
input uint              InpStartHour   =  8;          // Start hour of the trading session
input uint              InpHours       =  5;          // Session length
input ENUM_CHART_MODE   InpChartMode   =  CHART_BARS; // Chart mode
//--- indicator buffers
double            BufferCandleOpen[];
double            BufferCandleHigh[];
double            BufferCandleLow[];
double            BufferCandleClose[];
double            BufferColors[];
//--- global variables
int               start_hour;
int               hours;
bool              current_candle;
ENUM_CHART_MODE   prev_mode;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   start_hour=int(InpStartHour>23 ? 23 : InpStartHour);
   int diff=24-start_hour;
   hours=int((int)InpHours>diff ? diff : InpHours);
   current_candle=true;
   prev_mode=(ENUM_CHART_MODE)ChartGetInteger(0,CHART_MODE);
   ChartSetInteger(0,CHART_MODE,InpChartMode);
   ChartRedraw();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Specified time range candles ("+(string)start_hour+","+(string)hours+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0,CHART_MODE,prev_mode);
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
   if(rates_total<fmax(hours,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,3);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCandleOpen[i]=BufferCandleHigh[i]=BufferCandleLow[i]=BufferCandleClose[i]=EMPTY_VALUE;

      ENUM_CANDLE_TYPE type=CandleType(i,open,close,time);
      BufferColors[i]=3;
      if(type==CANDLE_TYPE_BULLISH)
        {
         BufferCandleOpen[i]=iOpen(NULL,PERIOD_CURRENT,i);
         BufferCandleHigh[i]=iHigh(NULL,PERIOD_CURRENT,i);
         BufferCandleLow[i]=iLow(NULL,PERIOD_CURRENT,i);
         BufferCandleClose[i]=iClose(NULL,PERIOD_CURRENT,i);
         BufferColors[i]=0;
        }
      else if(type==CANDLE_TYPE_BEARISH)
        {
         BufferCandleOpen[i]=iOpen(NULL,PERIOD_CURRENT,i);
         BufferCandleHigh[i]=iHigh(NULL,PERIOD_CURRENT,i);
         BufferCandleLow[i]=iLow(NULL,PERIOD_CURRENT,i);
         BufferCandleClose[i]=iClose(NULL,PERIOD_CURRENT,i);
         BufferColors[i]=1;
        }
      else if(type==CANDLE_TYPE_NEUTRAL)
        {
         BufferCandleOpen[i]=iOpen(NULL,PERIOD_CURRENT,i);
         BufferCandleHigh[i]=iHigh(NULL,PERIOD_CURRENT,i);
         BufferCandleLow[i]=iLow(NULL,PERIOD_CURRENT,i);
         BufferCandleClose[i]=iClose(NULL,PERIOD_CURRENT,i);
         BufferColors[i]=2;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает тип свечи                                             |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CandleType(int shift,const double &open[],const double &close[],const datetime &time[])
  {
   int total=start_hour+hours;
   for(int j=start_hour; j<total; j++)
     {
      int hour=(j==24 ? 0 : j>24 ? j-24 : j);
      if(TimeHour(time[shift])==hour || (current_candle && shift==0))
         return(close[shift] > open[shift] ? CANDLE_TYPE_BULLISH : close[shift] < open[shift] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_NEUTRAL);
     }
   return(CANDLE_TYPE_NONE);
  }
//+------------------------------------------------------------------+
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.hour;
  }
//+------------------------------------------------------------------+
