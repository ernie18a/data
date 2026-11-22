Calculation: TRIN threshold = SMA(TRIN close(T1, bar still forming, sampled on chart bars), threshold lookback) + threshold multiplier × population standard deviation(TRIN close(T1, bar still forming, sampled on chart bars), threshold lookback)
Long: TRIN close(T1, bar still forming, sampled on chart bars) > TRIN entry threshold
Long: TRIN close(T1, bar still forming, sampled on chart bars) > TRIN threshold
Exit: long, close(T1, last completed bar) > high(T1, previous bar)
Exit: long, close > high[1]
Exit: long, low <= entry price − stop-loss multiplier × population standard deviation(close, volatility lookback)
Long: TRIN index close > SMA(TRIN index close, T1, P1) + P2 × standard deviation(TRIN index close, T1, P1)