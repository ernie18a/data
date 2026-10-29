Calculation: Upper channel = XMA of high prices on the configured indicator timeframe, using the configured smoothing method and parameters; use the most recently completed bar.
Calculation: Lower channel = XMA of low prices on the configured indicator timeframe, using the same smoothing method and parameters as the upper channel; use the most recently completed bar.
Long: Current completed indicator-timeframe close > upper channel AND (previous completed indicator-timeframe close < previous lower channel OR previous close was between the previous lower and upper channels, inclusive)
Short: Current completed indicator-timeframe close < lower channel AND (previous completed indicator-timeframe close > previous upper channel OR previous close was between the previous lower and upper channels, inclusive)
Exit: Long, current completed indicator-timeframe close < lower channel
Exit: Short, current completed indicator-timeframe close > upper channel