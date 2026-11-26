Calculation: bullPower = SMA((close > open ? close - open : 0) * ((close > open ? volume : 0) / (SMA(volume, vortex lookback) + epsilon)), power smoothing lookback)
Calculation: bearPower = SMA((close < open ? open - close : 0) * ((close < open ? volume : 0) / (SMA(volume, vortex lookback) + epsilon)), power smoothing lookback)
Long: bullPower > bearPower
Short: bullPower < bearPower