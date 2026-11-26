Calculation: Volume-adjusted velocity = ((close - close[1]) / (high - low if high > low, otherwise minimum tick)) * (volume / SMA(volume, baseline lookback) if SMA(volume, baseline lookback) > 0, otherwise 1)
Calculation: Acceleration = Volume-adjusted velocity - Volume-adjusted velocity[acceleration lag]
Long: Acceleration > 0 AND ATR(ATR period) >= SMA(ATR(ATR period), baseline lookback)
Short: Acceleration <= 0 AND ATR(ATR period) >= SMA(ATR(ATR period), baseline lookback)