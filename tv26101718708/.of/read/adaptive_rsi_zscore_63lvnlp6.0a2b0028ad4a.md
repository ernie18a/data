Calculation: Z-score = (RSI − moving average of RSI) / standard deviation of RSI over the same lookback
Calculation: Dynamic long threshold = standard deviation of the Z-score × long multiplier; otherwise use the configured fixed long threshold
Calculation: Dynamic short threshold = −standard deviation of the Z-score × short multiplier; otherwise use the configured fixed short threshold
Long: Z-score crosses above the long threshold
Short: Z-score crosses below the short threshold
Exit: long, Z-score crosses below the short threshold