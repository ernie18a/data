Calculation: VWAP of close = VWAP(close)
Calculation: EMA of close with P3 = EMA(close, P3)
Long: EMA(close, P1) crosses above EMA(close, P2) AND close >= VWAP of close AND close >= EMA of close with P3 AND RSI(close, P4) > P5 AND RSI(close, P4) > prior-bar RSI(close, P4)
Exit: Long, close < EMA of close with P3 AND close < VWAP of close
Exit: Long, close < low of candle before entry