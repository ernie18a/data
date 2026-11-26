Calculation: candle midpoint = (high + low) / 2
Long: close > candle midpoint AND close[1] < candle midpoint[1]
Short: close < candle midpoint AND close[1] > candle midpoint[1]
Exit: long, close < candle midpoint
Exit: short, close > candle midpoint