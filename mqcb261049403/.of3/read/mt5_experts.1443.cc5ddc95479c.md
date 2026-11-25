Calculation: threshold distance = (highest(high, lookback) - lowest(low, lookback)) × offset percentage / 100
Calculation: prior signal direction = direction of the most recent earlier signal, or neutral if none
Long: On T1 bars, using the last completed bar, close > highest(high, lookback) - threshold distance AND prior signal direction != long
Short: On T1 bars, using the last completed bar, close < lowest(low, lookback) + threshold distance AND prior signal direction != short AND NOT (close > highest(high, lookback) - threshold distance AND prior signal direction != long)