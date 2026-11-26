Calculation: session VWAP = VWAP(hlc3)
Calculation: ATR margin = ATR(ATR lookback) * ATR margin multiplier
Long: on confirmed chart bars, close > session VWAP + ATR margin AND close > open AND close > high[1] AND (RSI filter disabled OR RSI(close, RSI lookback) > RSI threshold)
Short: on confirmed chart bars, close < session VWAP - ATR margin AND close < open AND close < low[1] AND (RSI filter disabled OR RSI(close, RSI lookback) < RSI threshold)