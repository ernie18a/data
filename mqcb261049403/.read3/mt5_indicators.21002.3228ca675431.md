Calculation: X2MA color state = 1 when X2MA(close, lookback) > X2MA(close, lookback)[1]; 2 when X2MA(close, lookback) < X2MA(close, lookback)[1]
Long: X2MA(close, lookback) > X2MA(close, lookback)[1]
Short: X2MA(close, lookback) < X2MA(close, lookback)[1]
Long: X2MA color state from T1, sampled on chart bars using the still-forming T1 bar, at the signal-bar offset = 2 AND the state one chart bar earlier != 2
Short: X2MA color state from T1, sampled on chart bars using the still-forming T1 bar, at the signal-bar offset = 1 AND the state one chart bar earlier != 1