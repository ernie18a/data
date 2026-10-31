Calculation: Trend oscillator = Apply a linear regression moving average to the selected OHLC-derived price. Smooth that average with a family of moving averages whose lookbacks increase by a fixed step. For each family member, add 1 if the regression average is greater than that moving average, otherwise subtract 1. Multiply the sum by 100, divide by the number of family members using integer division truncated toward zero, and smooth the result with a separately parameterized moving average.
Calculation: Volatility ratio = 100 times the short-lookback population standard deviation of close minus its lagged close, divided by the long-lookback population standard deviation of the same series; use zero if the denominator is zero.
Calculation: Signal values = Trend oscillator and volatility ratio on the same higher timeframe as each other, using either the last completed bar or the still-forming bar according to the selected signal-bar setting; earlier values refer to preceding bars of that timeframe.
Long: Chart-timeframe trend oscillator > 0.
Short: Chart-timeframe trend oscillator < 0.
Long: Signal trend oscillator > upper threshold AND previous signal trend oscillator <= upper threshold AND (volatility filter disabled OR signal volatility ratio > volatility threshold).
Short: Signal trend oscillator < lower threshold AND previous signal trend oscillator >= lower threshold AND (volatility filter disabled OR signal volatility ratio > volatility threshold).
Long: Signal trend oscillator > previous signal trend oscillator AND trend oscillator two signal bars ago > previous signal trend oscillator AND (volatility filter disabled OR signal volatility ratio > volatility threshold).
Short: Signal trend oscillator < previous signal trend oscillator AND trend oscillator two signal bars ago < previous signal trend oscillator AND (volatility filter disabled OR signal volatility ratio > volatility threshold).
Exit: long, signal trend oscillator < lower threshold OR signal trend oscillator < previous signal trend oscillator.
Exit: short, signal trend oscillator > upper threshold OR signal trend oscillator > previous signal trend oscillator.
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance.