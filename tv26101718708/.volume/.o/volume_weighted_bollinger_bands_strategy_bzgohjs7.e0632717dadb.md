Calculation: Weighted average = arithmetic mean of four EMAs with progressively longer lookbacks and session VWAP
Calculation: Upper band = SMA of the weighted average + standard deviation of the weighted average over the same lookback, multiplied by a parameter
Calculation: Lower band = SMA of the weighted average − standard deviation of the weighted average over the same lookback, multiplied by a parameter
Long: close > upper band AND previous close > current upper band
Short: close < lower band AND previous close < current lower band
Exit: long, close < lower band AND previous close < current lower band
Exit: short, close > upper band AND previous close > current upper band