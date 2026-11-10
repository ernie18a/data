Calculation: Momentum component = (close minus close a lookback ago) divided by ATR, or zero if ATR is zero; clamp to [-4, 4] and replace unavailable values with zero.
Calculation: Trend component = (shorter-period EMA of close minus longer-period EMA of close) divided by ATR, or zero if ATR is zero; clamp to [-4, 4] and replace unavailable values with zero.
Calculation: RSI component = (RSI of close minus 50) divided by 25; clamp to [-4, 4] and replace unavailable values with zero.
Calculation: Directional bias = sum, over the momentum, trend, and RSI components, of component × exp(abs(component) / positive attention temperature).
Long: Directional bias > 0
Short: Directional bias < 0