Calculation: volume delta = 0 when high = low; otherwise ((close - low) / (high - low) - (high - close) / (high - low)) * volume
Calculation: surge threshold = SMA(volume, volume lookback) + standard deviation(volume, same lookback) * surge multiplier
Long: volume > surge threshold AND EMA(volume delta, flow smoothing length) > 0
Short: volume > surge threshold AND EMA(volume delta, flow smoothing length) < 0