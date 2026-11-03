Calculation: Trend = close > short-term EMA > medium-term EMA > long-term EMA
Calculation: Pullback trend = short-term EMA > medium-term EMA > long-term EMA
Calculation: Relative strength = asset return over a lookback divided by benchmark return over the same lookback
Calculation: Swing compression = highest high minus lowest low over a lookback is below close times a range threshold
Calculation: Higher low = current low > low from a shorter lookback ago
Calculation: Near high = close divided by the highest high over a long lookback exceeds a proximity threshold
Calculation: Score = weighted sum of Trend, Pullback trend, Relative strength above its threshold, Swing compression, Higher low, volume above its moving average, Near high, and benchmark close above its short-term EMA above its long-term EMA
Long: Score >= setup threshold OR (Score >= higher elite threshold AND Trend AND Relative strength above its threshold AND benchmark close above its short-term EMA above its long-term EMA)