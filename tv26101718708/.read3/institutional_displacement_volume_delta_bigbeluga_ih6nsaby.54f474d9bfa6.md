Calculation: Body ratio = high == low ? 0 : abs(close - open) / (high - low)
Long: close > open AND volume > SMA(volume, volume lookback) × volume multiplier AND Body ratio >= minimum body percentage / 100
Short: close < open AND volume > SMA(volume, volume lookback) × volume multiplier AND Body ratio >= minimum body percentage / 100