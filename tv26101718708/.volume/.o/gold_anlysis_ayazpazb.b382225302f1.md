Calculation: Short-term EMA = EMA(close, shorter lookback)
Calculation: Long-term EMA = EMA(close, longer lookback)
Calculation: Smoothed low EMA = configured smoothing moving average of EMA(low, signal lookback)
Calculation: Smoothed high EMA = configured smoothing moving average of EMA(high, signal lookback)
Long: Short-term EMA > Long-term EMA AND high[1] < Smoothed low EMA AND close > high[1] AND close > open AND close[1] > open[1]
Long: high[1] < Smoothed low EMA AND close > high[1] AND close < Long-term EMA
Long: close[3] > open[3] AND close[2] > open[2] AND close[1] < open[1] AND close > open AND close > high[1]
Short: Short-term EMA < Long-term EMA AND low[1] > Smoothed high EMA AND close < low[1] AND close < open AND close[1] < open[1]
Short: low[1] > Smoothed high EMA AND close < low[1] AND close > Long-term EMA
Short: close[3] < open[3] AND close[2] < open[2] AND close[1] > open[1] AND close < open AND close < low[1]