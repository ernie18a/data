Calculation: Smoothed candle open, high, low, and close = apply the same selected smoothing method and lookback to the corresponding open, high, low, and close on the indicator timeframe; this timeframe may be higher, lower, or equal to the chart timeframe. Use the last completed indicator bar.
Long: smoothed close > smoothed open OR indicator-timeframe close > smoothed high + breakout level
Short: smoothed close <= smoothed open OR indicator-timeframe close < smoothed low - breakout level
Exit: long, indicator-timeframe close < smoothed low - breakout level
Exit: short, indicator-timeframe close > smoothed high + breakout level