Calculation: Short EMA = EMA(close, shorter lookback) on the chart timeframe
Calculation: Trend EMA = EMA(close, longer lookback) on a higher timeframe, using the last completed bar
Calculation: Fibonacci pullback level = highest high over a lookback × (1 − retracement fraction)
Long: close > Trend EMA AND RSI > RSI threshold AND ADX > ADX threshold AND ((close ≤ Short EMA × (1 + buffer) AND previous close > current Short EMA AND volume > volume SMA × volume threshold) OR (close ≤ Fibonacci pullback level AND previous close > Fibonacci pullback level)) AND (flat OR (long position AND position size below scaling cap))
Long: long position AND close ≤ Fibonacci pullback level AND previous close > Fibonacci pullback level AND close > Trend EMA AND RSI > RSI threshold AND ADX > ADX threshold
Exit: long, high ≥ entry price + ATR × profit target multiple OR low ≤ entry price − ATR × stop multiple