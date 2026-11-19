Calculation: Relative volume = volume / SMA(volume, volume lookback) if SMA(volume, volume lookback) > 0, otherwise 0
Calculation: Volume pressure = EMA((((2 * (close - low) / MAX(high - low, minimum tick size) - 1) + (close > open ? 1 : close < open ? -1 : 0)) / 2, pressure smoothing lookback) * Relative volume
Long: Volume pressure > 0
Short: Volume pressure <= 0