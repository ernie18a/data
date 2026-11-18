Calculation: MA spread = max(EMA(close, shortest lookback), EMA(open, middle lookback), EMA(close, longest lookback)) - min(EMA(close, shortest lookback), EMA(open, middle lookback), EMA(close, longest lookback))
Long: EMA(close, shortest lookback) > EMA(open, middle lookback) AND MA spread > ATR(lookback) * separation percentage / 100
Short: EMA(open, middle lookback) > EMA(close, shortest lookback) AND MA spread > ATR(lookback) * separation percentage / 100
Long: SMA(hl2, lookback) > SMA(hl2, lookback)[1] AND SMA(hl2, lookback)[1] <= SMA(hl2, lookback)[2]
Short: SMA(hl2, lookback) <= SMA(hl2, lookback)[1] AND SMA(hl2, lookback)[1] > SMA(hl2, lookback)[2]
Long: MACD line(close, shorter fast lookback, longer slow lookback) >= its signal line( signal lookback)
Short: MACD line(close, shorter fast lookback, longer slow lookback) < its signal line(signal lookback)