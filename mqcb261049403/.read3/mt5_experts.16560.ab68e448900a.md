Calculation: W = Williams %R(lookback, T1, last completed bar)
Long: On each T1 bar close, W >= upper level AND (slowdown filter disabled OR abs(W - W[1]) < slowdown threshold)
Short: On each T1 bar close, W <= lower level AND (slowdown filter disabled OR abs(W - W[1]) < slowdown threshold)