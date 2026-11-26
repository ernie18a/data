Calculation: PWMA = sum(close[n] * (lookback - n)^2) / sum((lookback - n)^2), for n = 0 to lookback - 1, calculated on T1 bars using the still-forming T1 bar
Calculation: Trend = bullish when close > PWMA on each of the last filter-lookback chart bars; bearish when close < PWMA on each of those bars; otherwise retain the prior trend; initially neutral
Long: Trend = bullish AND Trend[1] != bullish
Short: Trend = bearish AND Trend[1] != bearish