Calculation: Smoothed OHLC = apply the same configurable smoothing method and lookback separately to each OHLC series.
Calculation: Smoothed Heiken-Ashi close = (smoothed open + smoothed high + smoothed low + smoothed close) / 4.
Calculation: Smoothed Heiken-Ashi open = (previous smoothed Heiken-Ashi open + previous smoothed Heiken-Ashi close) / 2; initialize with smoothed open.
Long: Higher-timeframe, currently forming bar smoothed Heiken-Ashi close > smoothed Heiken-Ashi open
Short: Higher-timeframe, currently forming bar smoothed Heiken-Ashi close <= smoothed Heiken-Ashi open