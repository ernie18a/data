Calculation: Range-normalized volume = volume / max(high - low, minimum tick)
Calculation: Absorption z-score = (Range-normalized volume - SMA(Range-normalized volume, normalization lookback)) / max(STDEV(Range-normalized volume, normalization lookback), standard-deviation floor)
Long: SMA(Absorption z-score, smoothing length) > absorption threshold AND close < SMA(close, trend lookback) AND close < close[trend lookback]
Short: SMA(Absorption z-score, smoothing length) > absorption threshold AND close > SMA(close, trend lookback) AND close > close[trend lookback]