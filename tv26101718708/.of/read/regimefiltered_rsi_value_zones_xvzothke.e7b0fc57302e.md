Calculation: Smoothed price Z-score = EMA of (close − its lookback SMA) / its lookback standard deviation; use 0 when the standard deviation is 0
Long: RSI is above its moving average of RSI
Long: close is above its regime moving average
Long: smoothed price Z-score is above its entry threshold
Long: RSI enters the buy zone (current RSI ≤ buy-zone level AND previous RSI > buy-zone level)
Short: RSI is below its moving average of RSI
Short: close is below its regime moving average
Short: smoothed price Z-score is below its entry threshold
Short: RSI enters the sell zone (current RSI ≥ sell-zone level AND previous RSI < sell-zone level)