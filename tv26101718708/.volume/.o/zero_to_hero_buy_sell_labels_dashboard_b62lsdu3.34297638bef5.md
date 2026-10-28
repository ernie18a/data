Calculation: Fast EMA = exponential moving average of close with the shorter of the two EMA lookbacks
Calculation: Slow EMA = exponential moving average of close with the longer of the two EMA lookbacks
Calculation: Trend score = 60 if close > fast EMA AND fast EMA > slow EMA; else 30 if close > fast EMA OR fast EMA > slow EMA; else 0
Calculation: Regression slope score = 20 if the current linear-regression value of close is greater than its prior-bar value, -20 if lower, else 0
Calculation: RSI score = 20 if RSI is > 50 AND < 70; else 10 if RSI > 70 OR (RSI < 50 AND > 30); else 0
Calculation: Volume score = 20 if volume / its moving average >= minimum volume ratio; else 0
Calculation: Volatility score = 20 if ATR / close × 100 is >= minimum ATR percentage AND <= maximum ATR percentage; else 0
Calculation: Structure score = using the latest confirmed pivot high and pivot low, 20 if close > latest pivot high; else -20 if close < latest pivot low; else 15 if low > latest pivot low AND latest pivot low > its value ten bars earlier; else -15 if high < latest pivot high AND latest pivot high < its value ten bars earlier; else 0
Calculation: Long score = clamp(trend score + max(regression slope score, 0) + RSI score + volume score + volatility score + max(structure score, 0), 0, 100)
Calculation: Short score = clamp((100 - trend score) + max(-regression slope score, 0) + (20 - RSI score) + volume score + volatility score + max(-structure score, 0), 0, 100)
Long: long score >= long threshold AND bar is confirmed
Short: short score <= short threshold AND bar is confirmed