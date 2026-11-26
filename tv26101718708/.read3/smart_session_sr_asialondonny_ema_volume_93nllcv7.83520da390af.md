Calculation: session upper level = max(open, close) of each session's first completed T1 bar, carried forward on chart bars until that session's next first bar
Calculation: session lower level = min(open, close) of each session's first completed T1 bar, carried forward on chart bars until that session's next first bar
Calculation: upper session level = maximum of the Asia, London, and New York session upper levels
Calculation: lower session level = minimum of the Asia, London, and New York session lower levels
Long: close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND close > upper session level AND close > high[1] AND close > open AND volume > SMA(volume, volume lookback) * volume threshold
Long: close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND low <= upper session level AND close > upper session level
Short: close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND close < lower session level AND close < low[1] AND close < open AND volume > SMA(volume, volume lookback) * volume threshold
Short: close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND high >= lower session level AND close < lower session level