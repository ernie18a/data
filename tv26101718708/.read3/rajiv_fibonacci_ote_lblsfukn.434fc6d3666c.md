Calculation: T1 bullish = close > open on the last completed T1 bar, evaluated on chart bars
Calculation: T1 range = high - low of the last completed T1 bar, evaluated on chart bars
Calculation: Fib level 1 = if T1 bullish, high of the last completed T1 bar - (parameter 1 × T1 range), otherwise low of the last completed T1 bar + (parameter 1 × T1 range), evaluated on chart bars
Calculation: Fib level 2 = if T1 bullish, high of the last completed T1 bar - (parameter 2 × T1 range), otherwise low of the last completed T1 bar + (parameter 2 × T1 range), evaluated on chart bars
Long: On chart bars, close crosses above Fib level 2 AND close > Fib level 1
Short: On chart bars, close crosses below Fib level 2 AND close < Fib level 1