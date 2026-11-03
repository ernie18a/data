Calculation: PVSRA vector candle = classify volume and candle spread relative to surrounding bars as unusually active major or secondary bullish (close > open) or bearish (close < open) activity
Calculation: Average range = moving average of high minus low over a lookback
Calculation: Minimum gap size = configurable percentage of average range
Long: Bullish PVSRA vector candle OR low > previous high AND low - previous high >= minimum gap size
Short: Bearish PVSRA vector candle OR high < previous low AND previous low - high >= minimum gap size