Calculation: M = 100 × (EMA(close, lookback) / SMA(close, same lookback) − 1)
Calculation: M_T1 = 100 × (EMA(close, lookback, T1, bar still forming) / SMA(close, same lookback, T1, bar still forming) − 1), calculated on T1 bars and mapped onto chart bars
Long: M > 0
Short: M < 0
Long: M_T1 > 0
Short: M_T1 < 0