Calculation: VWAP = cumulative sum of (close × volume) divided by cumulative sum of volume, anchored to session start
Calculation: EMA = exponential moving average of close with length ema_length
Calculation: RSI = relative strength index of close with length rsi_length
Long: close crosses above VWAP AND RSI < long_rsi_threshold AND close > EMA
Short: close crosses below VWAP AND RSI > short_rsi_threshold AND close < EMA
Exit: long, close crosses below VWAP AND RSI > short_rsi_threshold AND close < EMA
Exit: short, close crosses above VWAP AND RSI < long_rsi_threshold AND close > EMA