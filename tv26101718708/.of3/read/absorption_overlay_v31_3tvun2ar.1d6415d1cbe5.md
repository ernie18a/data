Calculation: Volume per range = volume / max(high - low, minimum tick size)
Calculation: Smoothed absorption z-score = SMA((Volume per range - SMA(Volume per range, normalization lookback)) / max(STDEV(Volume per range, normalization lookback), minimum standard-deviation floor), smoothing lookback)
Calculation: Weighted absorption delta = Smoothed absorption z-score * ((close < SMA(close, trend lookback) AND close < close[trend lookback]) ? 1 : (close > SMA(close, trend lookback) AND close > close[trend lookback]) ? -1 : 0)
Long: Smoothed absorption z-score > absorption threshold AND close < SMA(close, trend lookback) AND close < close[trend lookback] AND current bar index - prior long absorption-signal bar index >= cooldown parameter (prior index initialized to zero)
Short: Smoothed absorption z-score > absorption threshold AND close > SMA(close, trend lookback) AND close > close[trend lookback] AND current bar index - prior short absorption-signal bar index >= cooldown parameter (prior index initialized to zero)
Long: Weighted absorption delta > 0
Short: Weighted absorption delta <= 0