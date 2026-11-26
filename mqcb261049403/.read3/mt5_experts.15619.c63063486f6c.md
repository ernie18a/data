Calculation: MaChannel bands on each completed T1 bar = moving average(high, smoothing method, smoothing length, phase, T1) + channel range and moving average(low, smoothing method, smoothing length, phase, T1) + channel range; in an uptrend, the lower band is the greater of its current value and prior value, and in a downtrend, the upper band is the lesser of its current value and prior value
Calculation: MaChannel trend on each completed T1 bar = prior trend, set to bullish if high > upper band, otherwise set to bearish if low < lower band, otherwise unchanged
Long: MaChannel trend crosses above zero on a completed T1 bar
Short: MaChannel trend crosses below zero on a completed T1 bar
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance