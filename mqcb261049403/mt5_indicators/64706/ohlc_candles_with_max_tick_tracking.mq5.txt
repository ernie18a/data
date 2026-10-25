//+------------------------------------------------------------------+
//|                      OHLC candles with max/min tick tracking.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrRed,clrGray

double OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[], ColorBuffer[];

input int lookback_bars = 50; // Lookback

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   SetIndexBuffer(0, OpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, LowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);

   ArraySetAsSeries(OpenBuffer, true);
   ArraySetAsSeries(HighBuffer, true);
   ArraySetAsSeries(LowBuffer, true);
   ArraySetAsSeries(CloseBuffer, true);
   ArraySetAsSeries(ColorBuffer, true);

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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   int limit = 0;

   if(prev_calculated == 0)
     {
      limit = lookback_bars;
      ArrayInitialize(HighBuffer, EMPTY_VALUE);
      ArrayInitialize(LowBuffer, EMPTY_VALUE);
      ArrayInitialize(OpenBuffer, EMPTY_VALUE);
      ArrayInitialize(CloseBuffer, EMPTY_VALUE);
     }
   else
     {
      limit = rates_total - prev_calculated;
      if(limit > 1) limit = 1;
     }

   MqlTick ticks[];
      
   for(int i = limit; i >= 0; i--)
     {
      OpenBuffer[i] = open[i];
      CloseBuffer[i] = close[i];
      ColorBuffer[i] = close[i] > open[i] ? 0 : close[i] < open[i] ? 1 : 2;

      datetime fromTime = time[i + 1];
      datetime toTime = time[i];
      ulong fromTimeMs = fromTime * 1000;
      ulong toTimeMs = toTime * 1000;

      int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_INFO, fromTimeMs, toTimeMs);
      double maxAsk = high[i];
      double minBid = low[i];

      if(copied > 0)
        {
         for(int k = 0; k < copied; k++)
           {
            if(ticks[k].ask > 0 && ticks[k].ask > maxAsk)
               maxAsk = ticks[k].ask;
            if(ticks[k].bid > 0 && ticks[k].bid < minBid)
               minBid = ticks[k].bid;
           }
        }

      HighBuffer[i] = maxAsk > 0 ? maxAsk : high[i];
      LowBuffer[i] = minBid > 0 ? minBid : low[i];
     }

   return rates_total;
  }
