Calculation: signal = clamp(sign(MA(close, shorter MA lookback) - MA(close, longer MA lookback)) + sign(RSI(close, shorter RSI lookback) - RSI(close, longer RSI lookback)), -1, 1), calculated on T1 bars
Long: signal(T1, bar still forming) > 0
Short: signal(T1, bar still forming) < 0
Long: signal(T1, last completed bar) > 0 AND signal(T1, bar still forming) <= 0, evaluated on chart bars using T1 values
Short: signal(T1, last completed bar) < 0 AND signal(T1, bar still forming) >= 0, evaluated on chart bars using T1 values
Exit: long, signal(T1, last completed bar) < 0, evaluated on chart bars using T1 values
Exit: short, signal(T1, last completed bar) > 0, evaluated on chart bars using T1 values