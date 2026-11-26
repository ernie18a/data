Calculation: impulse = abs(close - open) > high - max(close, open) + min(close, open) - low
Calculation: last confirmed swing high = last non-na PivotHigh(high, swing lookback, swing lookback)
Calculation: last confirmed swing low = last non-na PivotLow(low, swing lookback, swing lookback)
Long: low < last confirmed swing low[swing lookback] AND impulse AND close < open AND volume < SMA(volume, volume MA lookback)
Short: high > last confirmed swing high[swing lookback] AND impulse AND close > open AND volume < SMA(volume, volume MA lookback)