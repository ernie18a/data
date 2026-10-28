Calculation: Oversold = RSI is below its lower threshold
Calculation: Overbought = RSI is above its upper threshold
Calculation: Near VWAP = absolute difference between close and VWAP is below a threshold
Calculation: Trend strength = ATR divided by close
Calculation: Trending = trend strength is above a threshold
Calculation: VIX down = VIX is below its moving average
Calculation: VIX up = VIX is above its moving average
Calculation: MTF bullish = shorter-lookback EMA crosses above longer-lookback EMA on other-timeframe bars, using the current bar, which may still be forming
Calculation: MTF bearish = shorter-lookback EMA crosses below longer-lookback EMA on other-timeframe bars, using the current bar, which may still be forming
Long: shorter-lookback EMA crosses above longer-lookback EMA AND RSI is oversold AND close is above the longer-term EMA AND close is near VWAP AND VIX is down AND MTF is bullish AND trend strength is trending
Short: shorter-lookback EMA crosses below longer-lookback EMA AND RSI is overbought AND close is below the longer-term EMA AND close is near VWAP AND VIX is up AND MTF is bearish AND trend strength is trending