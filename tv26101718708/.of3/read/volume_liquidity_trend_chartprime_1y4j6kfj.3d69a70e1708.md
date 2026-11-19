Calculation: Kalman average = stabilization coefficient × source price + (1 − stabilization coefficient) × Kalman average[previous value bars back], treating an unavailable prior value as zero
Calculation: Trend state = bullish after close crosses above Kalman average + band multiplier × ATR(ATR lookback); bearish after close crosses below Kalman average − band multiplier × ATR(ATR lookback); otherwise previous state, initially bearish
Long: Trend state changes from bearish to bullish
Short: Trend state changes from bullish to bearish