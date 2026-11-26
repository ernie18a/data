Calculation: candle body ratio = if high = low then 0 else abs(close - open) / (high - low)
Calculation: relative volume = volume / SMA(volume, volume lookback)
Long: close >= open AND candle body ratio >= body conviction threshold AND relative volume >= high volume threshold
Short: close < open AND candle body ratio >= body conviction threshold AND relative volume >= high volume threshold