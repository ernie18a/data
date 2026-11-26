Calculation: Imbalance = 100 * SUM(volume * CLV, imbalance lookback) / SUM(volume, imbalance lookback), or 0 when the volume sum is 0; CLV = -1 when high = low, otherwise 2 * (close - low) / (high - low) - 1
Long: Imbalance >= 0
Short: Imbalance < 0
Long: Imbalance > the upper rolling linear-interpolation percentile of Imbalance over a percentile lookback longer than the imbalance lookback, using the upper percentile; use 0 if the percentile is unavailable
Short: Imbalance < the lower rolling linear-interpolation percentile of Imbalance over a percentile lookback longer than the imbalance lookback, using the lower percentile; use 0 if the percentile is unavailable
Long: close > SMA(close, trend lookback)
Short: close < SMA(close, trend lookback)
Long: On each chart bar, the previous completed chart bar's Imbalance > its upper rolling linear-interpolation percentile threshold AND its close > SMA(close, trend lookback) on that bar AND at least the cooldown period has elapsed since the previous long signal
Short: On each chart bar, the previous completed chart bar's Imbalance < its lower rolling linear-interpolation percentile threshold AND its close < SMA(close, trend lookback) on that bar AND at least the cooldown period has elapsed since the previous short signal