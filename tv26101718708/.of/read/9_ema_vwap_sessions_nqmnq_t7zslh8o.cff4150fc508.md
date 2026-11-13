Calculation: VWAP = cumulative sum of (volume * (high+low+close)/3) / cumulative volume, reset at the start of each trading day (chart timeframe)
Long: EMA(close) crosses above VWAP on the current bar (previous bar EMA <= previous bar VWAP AND current EMA > current VWAP) AND close > VWAP AND EMA > EMA from a few bars earlier (rising slope) AND abs(previous bar EMA - previous bar VWAP) >= a minimum distance
Short: EMA(close) crosses below VWAP on the current bar (previous bar EMA >= previous bar VWAP AND current EMA < current VWAP) AND close < VWAP AND EMA < EMA from a few bars earlier (falling slope) AND abs(previous bar EMA - previous bar VWAP) >= a minimum distance
Long: EMA(close) > VWAP (bullish bias state)
Short: EMA(close) < VWAP (bearish bias state)