Calculation: Basis = EMA(close, lookback)
Calculation: Upper band = Basis + multiplier × standard deviation of close over the same lookback
Calculation: Lower band = Basis − multiplier × standard deviation of close over the same lookback
Long: close crosses above the upper band AND volume > SMA(volume, lookback) × volume threshold
Short: close crosses below the lower band AND volume > SMA(volume, lookback) × volume threshold