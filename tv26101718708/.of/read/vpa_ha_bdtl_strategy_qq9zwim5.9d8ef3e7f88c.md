Calculation: High volume = volume > its longer-term simple moving average × a configurable multiplier
Calculation: Wide spread = high − low > the longer-term simple moving average of high − low × a configurable multiplier
Calculation: Bullish VPA = close > open AND high volume AND wide spread
Calculation: Bearish VPA = close < open AND high volume AND wide spread
Calculation: Buying pressure = lower wick > body size × a configurable multiplier AND high volume
Calculation: Selling pressure = upper wick > body size × a configurable multiplier AND high volume
Calculation: Downtrend line = projected line through the latest two confirmed pivot highs when the newer pivot high is lower than the older one; each pivot uses the same configurable lookback on both sides
Calculation: Downtrend line breakout = previous close ≤ previous downtrend line AND current close > current downtrend line
Calculation: EMA slope = percentage change in a longer-term exponential moving average over a shorter lag
Calculation: Trailing stop = highest value so far while long of close − ATR × a configurable multiplier
Long: Downtrend line breakout OR Buying pressure OR (Bullish VPA AND Downtrend line breakout AND EMA slope > a configurable lower threshold)
Short: Selling pressure
Exit: Long, close < trailing stop OR Bearish VPA