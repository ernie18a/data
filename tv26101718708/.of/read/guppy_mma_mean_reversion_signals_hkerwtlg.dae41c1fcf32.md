Calculation: Short-term EMA 1 = EMA of close using the shortest lookback in the short-term EMA group
Calculation: Long-term EMA 1 = EMA of close using the shortest lookback in the long-term EMA group
Calculation: Long-term EMA 6 = EMA of close using the longest lookback in the long-term EMA group
Calculation: Candle volume delta = 0 if high = low; otherwise (close - open) / (high - low) × volume
Calculation: CVD = cumulative sum of candle volume delta
Calculation: Smoothed CVD = EMA of CVD
Calculation: ATR = average true range
Calculation: RSI = relative strength index of close
Long: Long-term EMA 1 > Long-term EMA 6 AND low ≤ Long-term EMA 1 AND previous bar low > previous bar Long-term EMA 1 AND (ATR filter disabled OR abs(close - Long-term EMA 1) ≥ ATR × ATR multiplier) AND (CVD filter disabled OR CVD > Smoothed CVD) AND (RSI filter disabled OR RSI < overbought threshold) AND (cooldown disabled OR bars since previous long signal ≥ cooldown length)
Short: Long-term EMA 1 < Long-term EMA 6 AND high ≥ Long-term EMA 1 AND previous bar high < previous bar Long-term EMA 1 AND (ATR filter disabled OR abs(close - Long-term EMA 1) ≥ ATR × ATR multiplier) AND (CVD filter disabled OR CVD < Smoothed CVD) AND (RSI filter disabled OR RSI > oversold threshold) AND (cooldown disabled OR bars since previous short signal ≥ cooldown length)
Exit: Long, Long-term EMA 1 > Long-term EMA 6 AND high ≥ Short-term EMA 1 AND previous bar high < previous bar Short-term EMA 1
Exit: Short, Long-term EMA 1 < Long-term EMA 6 AND low ≤ Short-term EMA 1 AND previous bar low > previous bar Short-term EMA 1