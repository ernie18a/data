Calculation: Trigger = clamp(sign(MA(close, shorter MA lookback) - MA(close, longer MA lookback)) + sign(RSI(close, shorter RSI lookback) - RSI(close, longer RSI lookback)), -1, 1)
Long: On chart bars using T1 values, Trigger on the last completed T1 bar > 0 AND Trigger on the still-forming T1 bar <= 0
Short: On chart bars using T2 values, Trigger on the last completed T2 bar < 0 AND Trigger on the still-forming T2 bar >= 0
Exit: Long, On chart bars using T1 values, Trigger on the last completed T1 bar < 0
Exit: Short, On chart bars using T2 values, Trigger on the last completed T2 bar > 0