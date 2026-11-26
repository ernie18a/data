Long: RSI(RSI source, RSI lookback) > MovingAverage(RSI(RSI source, RSI lookback), RSI MA type, RSI MA lookback)
Short: RSI(RSI source, RSI lookback) <= MovingAverage(RSI(RSI source, RSI lookback), RSI MA type, RSI MA lookback)
Long: close > MovingAverage(close, regime MA type, regime MA lookback), where regime MA lookback is longer than RSI MA lookback
Short: close <= MovingAverage(close, regime MA type, regime MA lookback), where regime MA lookback is longer than RSI MA lookback
Long: EMA(Z-score(close, Z-score lookback), Z-score smoothing lookback) > entry threshold
Short: EMA(Z-score(close, Z-score lookback), Z-score smoothing lookback) <= entry threshold
Long: RSI(RSI source, RSI lookback) <= buy zone level
Long: RSI(RSI source, RSI lookback) <= buy zone level AND RSI(RSI source, RSI lookback)[1] > buy zone level
Exit: long, RSI(RSI source, RSI lookback) >= sell zone level
Exit: long, RSI(RSI source, RSI lookback) >= sell zone level AND RSI(RSI source, RSI lookback)[1] < sell zone level