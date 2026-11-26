Calculation: Trend basis = EMA(selected moving average(trend source, trend lookback), smoothing lookback)
Calculation: Trend strength = if ATR(ATR lookback) ≠ 0 then (trend basis - trend basis[1]) / (normalization factor * ATR(ATR lookback)) else 0
Calculation: Upper reversal band = EMA(trend basis + band sensitivity * stdev(trend source, trend lookback), smoothing lookback)
Calculation: Lower reversal band = EMA(trend basis - band sensitivity * stdev(trend source, trend lookback), smoothing lookback)
Long: trend strength > trend threshold
Short: trend strength < -trend threshold
Long: low[1] < lower reversal band[1] AND close[1] < open[1] AND close > open
Short: high[1] > upper reversal band[1] AND close[1] > open[1] AND close < open