Calculation: latest confirmed pivot high = most recent non-na PivotHigh(high, lookback, lookback)
Calculation: volume filter passes = filter disabled OR volume > SMA(volume, lookback) * multiplier
Long: EMA(close, shorter lookback) > EMA(close, medium lookback) AND EMA(close, medium lookback) > EMA(close, longer lookback) AND close > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, medium lookback) AND EMA(close, medium lookback) < EMA(close, longer lookback) AND close < EMA(close, longer lookback)
Long: latest confirmed pivot high exists AND close[1] <= latest confirmed pivot high AND close > latest confirmed pivot high AND close > open AND EMA(close, shorter lookback) > EMA(close, medium lookback) AND EMA(close, medium lookback) > EMA(close, longer lookback) AND close > EMA(close, longer lookback) AND volume filter passes
Long: crossover(close, EMA(close, medium lookback)) AND close > EMA(close, longer lookback) AND volume filter passes