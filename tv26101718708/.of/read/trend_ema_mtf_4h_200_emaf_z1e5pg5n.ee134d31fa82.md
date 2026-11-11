Calculation: Trend EMA = EMA of close on a configurable timeframe; for a higher timeframe, use the last completed bar and carry its value forward; for a lower timeframe, use the last completed lower-timeframe bar within each chart bar.
Calculation: Trend direction = direction of the most recent unequal comparison between a completed trend-timeframe EMA and its preceding trend-timeframe EMA; retain the previous direction when equal and initialize as up.
Long: Trend direction = up
Short: Trend direction = down
Long: Chart close >= selected trend EMA
Short: Chart close < selected trend EMA