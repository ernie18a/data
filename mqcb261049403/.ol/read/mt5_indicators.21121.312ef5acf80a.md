Calculation: Smoothed period candle = apply the selected moving-average method to each chart-timeframe bar’s open, high, low, and close; candle open is the smoothed open from the longer lookback, candle close is the current smoothed close, candle high is the highest smoothed high over the shorter lookback, and candle low is the lowest smoothed low over the shorter lookback. For the higher-timeframe version, calculate on aggregated higher-timeframe bars and use the bar still forming.
Long: chart-timeframe smoothed period candle close >= open
Short: chart-timeframe smoothed period candle close < open
Long: higher-timeframe smoothed period candle close >= open
Short: higher-timeframe smoothed period candle close < open