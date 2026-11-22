Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND close >= VWAP(close) AND close >= EMA(close, trend lookback longer than the crossover EMA lookbacks) AND RSI(close, RSI lookback) > RSI threshold AND RSI(close, RSI lookback) > RSI(close, RSI lookback)[1]
Exit: long, (close < EMA(close, trend lookback) AND close < VWAP(close)) OR close < low of the bar immediately preceding the long-entry bar
Calculation: VWAP of close = VWAP(close)
Calculation: EMA of close with P3 = EMA(close, P3)
Long: EMA(close, P1) crosses above EMA(close, P2) AND close >= VWAP of close AND close >= EMA of close with P3 AND RSI(close, P4) > P5 AND RSI(close, P4) > prior-bar RSI(close, P4)
Exit: Long, close < EMA of close with P3 AND close < VWAP of close
Exit: Long, close < low of candle before entry