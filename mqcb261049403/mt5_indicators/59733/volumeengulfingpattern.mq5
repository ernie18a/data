//+------------------------------------------------------------------+
//|                                       VolumeEngulfingPattern.mq5 |
//|                                                Ezequiel Henrique |
//|                         https://www.mql5.com/en/users/ezhenrique |
//+------------------------------------------------------------------+
#property copyright "2024, @ezhenrique"
#property link      "https://www.mql5.com/en/users/ezhenrique"
#property version   "2.00"
#property description "Detects bullish and bearish engulfing candlestick patterns."
#property description "Optional volume filter: highlights patterns with increasing volume."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//+------------------------------------------------------------------+
//|                         Input Parameters                         |
//+------------------------------------------------------------------+
input color BullishArrowColor   = clrLimeGreen;    // Color of the arrow for bullish engulfing
input color BearishArrowColor   = clrTomato;       // Color of the arrow for bearish engulfing
input bool  UseVolumeFilter     = true;            // Enable volume confirmation

//+------------------------------------------------------------------+
//|                              Enums                               |
//+------------------------------------------------------------------+
enum CANDLE_MOVEMENT
  {
   UP = 1,
   DOWN = 0
  };

enum ENGULFING_PATTERN
  {
   BULLISH = 1,
   BEARISH = 0,
   NONE = -1
  };

//+------------------------------------------------------------------+
//|                             Structures                           |
//+------------------------------------------------------------------+
struct CANDLE_STRUCTURE
  {
   double            open;
   double            high;
   double            low;
   double            close;
   long              volume;
   datetime          time;
   CANDLE_MOVEMENT   move;
  };

//+------------------------------------------------------------------+
//|                       Global Variables                           |
//+------------------------------------------------------------------+
string objectNames[];
double bullishBuffer[];
double bearishBuffer[];

//+------------------------------------------------------------------+
//|                  Engulfing Pattern Function                      |
//+------------------------------------------------------------------+
ENGULFING_PATTERN isEngulfingPattern(CANDLE_STRUCTURE &prevCandle, CANDLE_STRUCTURE &currentCandle)
  {
   bool bullishCondition1 = (prevCandle.move == DOWN) && (currentCandle.move == UP);
   bool bullishCondition2 = (currentCandle.open <= prevCandle.close) && (currentCandle.close > prevCandle.open);

   bool bearishCondition1 = (prevCandle.move == UP) && (currentCandle.move == DOWN);
   bool bearishCondition2 = (currentCandle.open >= prevCandle.close) && (currentCandle.close < prevCandle.open);

   bool volumeCondition;

   if(UseVolumeFilter)
     {
      volumeCondition = currentCandle.volume > prevCandle.volume;
     }
   else
     {
      volumeCondition = true;
     }


   if(bullishCondition1 && bullishCondition2 && volumeCondition)
     {
      return BULLISH;
     }

   if(bearishCondition1 && bearishCondition2 && volumeCondition)
     {
      return BEARISH;
     }

   return NONE;
  }

//+------------------------------------------------------------------+
//|                            OnInit Function                       |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, bullishBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, bearishBuffer, INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);

   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, BullishArrowColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, BearishArrowColor);

   PlotIndexSetString(0, PLOT_LABEL, "Bullish Engulfing");
   PlotIndexSetString(1, PLOT_LABEL, "Bearish Engulfing");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                         OnCalculate Function                     |
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

   CANDLE_STRUCTURE candles[];
   ArrayResize(candles, rates_total);

   ArrayInitialize(bullishBuffer, EMPTY_VALUE);
   ArrayInitialize(bearishBuffer, EMPTY_VALUE);

   for(int i=0; i < rates_total; i++)
     {
      candles[i].open   = open[i];
      candles[i].high   = high[i];
      candles[i].low    = low[i];
      candles[i].close  = close[i];
      candles[i].volume = tick_volume[i];
      candles[i].time   = time[i];
      candles[i].move   = (close[i] > open[i] ? UP : DOWN);
     }

   for(int i=1; i < rates_total - 1; i++)
     {
      ENGULFING_PATTERN pattern = isEngulfingPattern(candles[i - 1], candles[i]);

      if(pattern == BULLISH)
        {
         bullishBuffer[i] = low[i] - (_Point * 10);
        }

      if(pattern == BEARISH)
        {
         bearishBuffer[i] = high[i] + (_Point * 10);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
