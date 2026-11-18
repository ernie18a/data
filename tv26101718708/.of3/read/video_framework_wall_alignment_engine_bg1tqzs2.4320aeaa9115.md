Calculation: Delta = ((close - open) / (high - low)) * volume
Long: volume > SMA(volume, volume lookback) * volume multiplier AND high > low AND abs(close - open) / (high - low) * 100 <= maximum body percent AND Delta < 0
Short: volume > SMA(volume, volume lookback) * volume multiplier AND high > low AND abs(close - open) / (high - low) * 100 <= maximum body percent AND Delta > 0