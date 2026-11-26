Calculation: Up/down volume ratio = SUM(volume where close > close[1], up/down lookback) / SUM(volume where close < close[1], up/down lookback)
Long: volume / SMA(volume, volume-average lookback) >= relative-volume threshold AND (close - low) / (high - low) >= close-range threshold
Long: Up/down volume ratio >= up/down ratio threshold
Short: Up/down volume ratio < up/down ratio threshold