//+------------------------------------------------------------------+
//|                                                Other_Candles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.01"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Candle"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen,clrOrangeRed,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input color    InpColorBullish   =  clrLimeGreen;  // Bullish candle color
input color    InpColorBearish   =  clrOrangeRed;  // Bearish candle color
//--- indicator buffers
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
double         BufferColors[];
//--- enums
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH, // Бычья свеча
   CANDLE_TYPE_BEARISH, // Медвежья свеча
   CANDLE_TYPE_DOJI     // Доджи
  };
//--- structures
struct SDataCandles
  {
   ENUM_CANDLE_TYPE  type;             // Тип свечи
   double            body_size;        // Размер тела свечи
   double            shadow_up_size;   // Размер верхней тени
   double            shadow_dn_size;   // Размер нижней тени
  } candle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
//--- settings plots parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   string symbol=Symbol();
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,InpColorBullish);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,InpColorBearish);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Other candles");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
   ArraySetAsSeries(BufferColors,true);
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
   if(rates_total<1) return 0;
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferOpen,0);
      ArrayInitialize(BufferHigh,0);
      ArrayInitialize(BufferLow,0);
      ArrayInitialize(BufferClose,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      SetCandleParams(i,open,high,low,close);
      BufferOpen[i]=0;
      if(candle.type==CANDLE_TYPE_BULLISH)
        {
         BufferColors[i]=0;
         BufferHigh[i]=candle.body_size+candle.shadow_up_size;
         BufferClose[i]=candle.body_size;
         BufferLow[i]=BufferOpen[i]-candle.shadow_dn_size;
        }
      else if(candle.type==CANDLE_TYPE_BEARISH)
        {
         BufferColors[i]=1;
         BufferLow[i]=-candle.body_size-candle.shadow_dn_size;
         BufferClose[i]=-candle.body_size;
         BufferHigh[i]=candle.shadow_up_size;
        }
      else
        {
         BufferClose[i]=0;
         BufferHigh[i]=candle.shadow_up_size;
         BufferLow[i]=-candle.shadow_dn_size;
         BufferColors[i]=2;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает параметры свечи                                       |
//+------------------------------------------------------------------+
void SetCandleParams(const int index,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   ZeroMemory(candle);
   candle.type=CandleType(index,open,close);
   candle.body_size=fabs(open[index]-close[index]);
   candle.shadow_up_size=high[index]-fmax(open[index],close[index]);
   candle.shadow_dn_size=fmin(open[index],close[index])-low[index];
  }
//+------------------------------------------------------------------+
//| Возвращает тип свечи                                             |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CandleType(const int index,const double &open[],const double &close[])
  {
   return(close[index]>open[index] ? CANDLE_TYPE_BULLISH : close[index]<open[index] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_DOJI);
  }
//+------------------------------------------------------------------+
