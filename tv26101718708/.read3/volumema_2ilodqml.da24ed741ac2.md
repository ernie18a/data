Calculation: Directional volume = (signed-volume mode ? sign(close - close[1]) : 1) * volume
Long: SMA(Directional volume, lookback) > 0
Short: SMA(Directional volume, lookback) < 0