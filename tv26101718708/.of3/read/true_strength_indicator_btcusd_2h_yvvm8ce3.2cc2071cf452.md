Calculation: momentum = TSI(close(T1, still-forming bar), longer TSI lookback, shorter TSI lookback), calculated on chart bars using T1 close values
Calculation: relative strength = RSI(close(T1, still-forming bar), separate RSI lookback), calculated on chart bars using T1 close values
Calculation: trend line = EMA(momentum, separate signal lookback), calculated on chart bars
Long: crossover(momentum, trend line) OR (relative strength > RSI midline threshold AND momentum != trend line) OR relative strength > upper RSI threshold
Short: crossunder(momentum, trend line) OR (relative strength < RSI midline threshold AND momentum != trend line) OR relative strength < lower RSI threshold