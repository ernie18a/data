Calculation: Volume threshold = nearest-rank percentile of volume over its lookback.
Calculation: Bullish order block = the most recent bearish candle within 50 bars before a confirmed swing low, if its volume is at least the volume threshold on that candle; its zone is that candle’s high to low.
Calculation: Bearish order block = the most recent bullish candle within 50 bars before a confirmed swing high, if its volume is at least the volume threshold on that candle; its zone is that candle’s high to low.
Long: A bullish order block forms OR close > the high of any unmitigated bearish order block.
Short: A bearish order block forms OR close < the low of any unmitigated bullish order block.