Calculation: Low-source smoothing = selected moving average(EMA(low, source lookback), smoothing lookback)
Calculation: High-source smoothing = selected moving average(EMA(high, source lookback), smoothing lookback)
Long: EMA(close, shorter trend lookback) > EMA(close, longer trend lookback)
Short: EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)
Long: high[1] < Low-source smoothing AND close > high[1] AND (trend filter disabled OR EMA(close, shorter trend lookback) > EMA(close, longer trend lookback)) AND (two-candle filter disabled OR close > open AND close[1] > open[1])
Short: low[1] > High-source smoothing AND close < low[1] AND (trend filter disabled OR EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)) AND (two-candle filter disabled OR close < open AND close[1] < open[1])
Long: EMA(close, shorter trend lookback) crosses above EMA(close, longer trend lookback)
Short: EMA(close, shorter trend lookback) crosses below EMA(close, longer trend lookback)
Long: close[3] > open[3] AND close[2] > open[2] AND close[1] < open[1] AND close > open AND close > high[1]
Short: close[3] < open[3] AND close[2] < open[2] AND close[1] > open[1] AND close < open AND close < low[1]
Long: high[1] < Low-source smoothing AND close > high[1] AND (trend filter disabled OR EMA(close, shorter trend lookback) > EMA(close, longer trend lookback)) AND (two-candle filter disabled OR close > open AND close[1] > open[1]) AND close < EMA(close, longer trend lookback)
Short: low[1] > High-source smoothing AND close < low[1] AND (trend filter disabled OR EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)) AND (two-candle filter disabled OR close < open AND close[1] < open[1]) AND close > EMA(close, longer trend lookback)