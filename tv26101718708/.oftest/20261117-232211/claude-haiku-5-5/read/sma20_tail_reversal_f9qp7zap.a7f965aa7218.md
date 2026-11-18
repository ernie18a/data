Calculation: Bullish candle = close > open AND high - close < wick ratio * (close - open)
Calculation: Bearish candle = close < open AND close - low < wick ratio * (open - close)
Calculation: Base long = volume > SMA(volume, volume lookback) AND Bullish candle AND high < SMA(close, price lookback) AND low < SMA(close, price lookback)
Calculation: Base short = volume > SMA(volume, volume lookback) AND Bearish candle AND high > SMA(close, price lookback) AND low > SMA(close, price lookback)
Calculation: Last base was long = the most recent prior bar where Base long or Base short is true is a bar where Base long is true
Calculation: Low of last base long = low at the most recent prior bar where Base long is true
Long: Base long AND Last base was long AND low > Low of last base long