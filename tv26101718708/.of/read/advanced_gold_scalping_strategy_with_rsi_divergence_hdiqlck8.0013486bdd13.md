Calculation: Bullish divergence = a confirmed RSI pivot low is higher than the preceding confirmed RSI pivot low, while the price low at the current pivot is lower than the price low at the preceding pivot, and the preceding pivot is within the configured divergence lookback range
Calculation: Bearish divergence = a confirmed RSI pivot high is lower than the preceding confirmed RSI pivot high, while the price high at the current pivot is higher than the price high at the preceding pivot, and the preceding pivot is within the configured divergence lookback range
Long: Bullish divergence AND RSI < oversold threshold
Short: Bearish divergence AND RSI > overbought threshold
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance