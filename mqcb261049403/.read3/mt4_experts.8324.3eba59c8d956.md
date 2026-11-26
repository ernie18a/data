Calculation: EMA spread = EMA(close, shorter lookback)[1] - EMA(close, longer lookback)[1]
Long: EMA spread < long-entry EMA-spread threshold AND RSI(close, shorter RSI lookback)[1] < long-entry RSI threshold
Short: EMA spread > short-entry EMA-spread threshold AND RSI(close, longer RSI lookback)[1] > short-entry RSI threshold