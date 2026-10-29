Calculation: Low smoothing average = SMA of EMA(low)
Calculation: High smoothing average = SMA of EMA(high)
Long: EMA(100) > EMA(200) AND high[1] < Low smoothing average AND close > high[1] AND close > open AND close[1] > open[1]
Short: EMA(100) < EMA(200) AND low[1] > High smoothing average AND close < low[1] AND close < open AND close[1] < open[1]
Long: EMA(100) crosses above EMA(200)
Short: EMA(100) crosses below EMA(200)
Long: EMA(100) > EMA(200)
Short: EMA(100) < EMA(200)
Long: close > open AND close[1] < open[1] AND close[2] > open[2] AND close[3] > open[3] AND close > high[1]
Short: close < open AND close[1] > open[1] AND close[2] < open[2] AND close[3] < open[3] AND close < low[1]
Long: EMA(100) > EMA(200) AND high[1] < Low smoothing average AND close > high[1] AND close > open AND close[1] > open[1] AND close < EMA(200)
Short: EMA(100) < EMA(200) AND low[1] > High smoothing average AND close < low[1] AND close < open AND close[1] < open[1] AND close > EMA(200)