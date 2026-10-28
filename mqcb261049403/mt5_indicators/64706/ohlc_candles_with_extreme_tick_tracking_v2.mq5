//+------------------------------------------------------------------+
//| OHLC candles with max/min tick tracking (optimized version)      |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrRed,clrGray

double OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[], ColorBuffer[];
input int lookback_bars = 50;

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

   return INIT_SUCCEEDED;
  }

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
     
   // ---- Retrieve all ticks for lookback range just once ----
   datetime fromTime = time[lookback_bars];
   datetime toTime   = time[0];
   ulong fromMs = (ulong)fromTime * 1000;
   ulong toMs   = (ulong)toTime * 1000;

   MqlTick ticks[];
   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_INFO, fromMs, toMs);
   if(copied <= 0)
      return rates_total;


   for(int i = limit; i >= 0; i--)
     {
      datetime barStart = time[i + 1];
      datetime barEnd   = time[i];

      double maxAsk = high[i];
      double minBid = low[i];

      for(int k = 0; k < copied; k++)
        {
         if(k < copied && ticks[k].time_msc >= barStart*1000 && ticks[k].time_msc <= barEnd*1000)
           {
            if(ticks[k].ask > 0 && ticks[k].ask > maxAsk)
               maxAsk = ticks[k].ask;
            if(ticks[k].bid > 0 && ticks[k].bid < minBid)
               minBid = ticks[k].bid;
           }
           
           if(ticks[k].time_msc >= barEnd*1000) 
            continue;
        }

      OpenBuffer[i] = open[i];
      CloseBuffer[i] = close[i];
      HighBuffer[i] = maxAsk > 0 ? maxAsk : high[i];
      LowBuffer[i] = minBid > 0 ? minBid : low[i];
      ColorBuffer[i] = close[i] > open[i] ? 0 : close[i] < open[i] ? 1 : 2;
     }

   return rates_total;
  }
