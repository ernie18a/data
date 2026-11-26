Calculation: Signal = clamp(sign(MA(close, shorter MA lookback) - MA(close, longer MA lookback)) + sign(RSI(close, shorter RSI lookback) - RSI(close, longer RSI lookback)), -1, 1)
Long: Signal[1] > 0 AND Signal[0] <= 0
Short: Signal[1] < 0 AND Signal[0] >= 0
Exit: long, Signal[1] < 0
Exit: short, Signal[1] > 0