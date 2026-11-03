Calculation: Lower threshold = the highest value over 14 consecutive bars of close minus an ATR multiple; upper threshold = the lowest value over 14 consecutive bars of close plus the same ATR multiple.
Calculation: Direction = short if close < lower threshold; otherwise long if close > upper threshold; otherwise retain the previous direction. Initially direction is undefined. Calculate thresholds and direction on the chart timeframe, or on a higher timeframe using its still-forming bar.
Long: Direction = long
Short: Direction = short