Calculation: EMA alignment score = +1 if the shorter-lookback close EMA is above the longer-lookback close EMA, -1 if below, otherwise 0
Calculation: Price deviation score = +1 if (close - close EMA baseline) / standard deviation of close over its lookback is below the negative deviation threshold, -1 if above the positive deviation threshold, otherwise 0
Calculation: Volume pressure score = if RSI of volume over its lookback divided by 50 exceeds its threshold, +1 when close > open, -1 when close < open, otherwise 0; if the volume condition is false, score 0
Calculation: RSI momentum score = +1 if RSI of close is above 50 and its smoothed value is rising, -1 if RSI of close is below 50 and its smoothed value is falling, otherwise 0
Calculation: Structural position score = +1 if close is above the midpoint between the highest high and lowest low over the lookback, -1 if below, otherwise 0
Calculation: Volatility context score = +1 if the shorter-lookback ATR divided by the longer-lookback ATR is below the low threshold, -1 if above the high threshold, otherwise 0
Calculation: Composite score = sum of the six scores above divided by 6
Long: Composite score > long threshold AND the prior confirmed bar's composite score was not above the long threshold
Short: Composite score < short threshold AND the prior confirmed bar's composite score was not below the short threshold