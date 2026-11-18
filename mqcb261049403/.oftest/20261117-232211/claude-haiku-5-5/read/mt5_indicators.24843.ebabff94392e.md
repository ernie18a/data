Calculation: avg = EMA(close, lookback) on T1 bars, using the bar still forming
Calculation: trend = up if avg > avg[1], down if avg < avg[1], otherwise trend[1]; computed on T1 bars, and each chart bar takes the value of the T1 bar still forming
Long: trend = up
Short: trend = down