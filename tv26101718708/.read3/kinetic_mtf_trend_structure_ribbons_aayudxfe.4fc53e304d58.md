Calculation: GMMA state n = 1 if EMA(close, shorter lookback n, T1, last completed bar) is above every EMA(close, longer lookback k, T1, last completed bar), k = 1 to 6; -1 if it is below every one; otherwise 0
Calculation: GMMA count = sum of GMMA state n for n = 1 to 5
Calculation: Gaussian line = LinearRegression(GaussianFilter(close, length, poles), smoothing length, offset)
Calculation: Gaussian trend = 1 if Gaussian line > SuperTrend(Gaussian line, factor, ATR length), otherwise -1
Long: GMMA count = 5 AND GMMA state 6 crosses above 0
Long: Gaussian trend(T2, last completed bar) crosses above 0
Long: Gaussian trend(T2, last completed bar) > 0
Short: GMMA count = -5 AND GMMA state 6 crosses below 0
Short: Gaussian trend(T2, last completed bar) crosses below 0
Short: Gaussian trend(T2, last completed bar) < 0
Short: EMA(close, ribbon lookback 1, T3, last completed bar) < EMA(close, ribbon lookback 1, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 2, T3, last completed bar) < EMA(close, ribbon lookback 2, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 3, T3, last completed bar) < EMA(close, ribbon lookback 3, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 4, T3, last completed bar) < EMA(close, ribbon lookback 4, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 5, T3, last completed bar) < EMA(close, ribbon lookback 5, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 6, T3, last completed bar) < EMA(close, ribbon lookback 6, T3, last completed bar)[2]
Short: EMA(close, ribbon lookback 7, T4, last completed bar) < EMA(close, ribbon lookback 7, T4, last completed bar)[2]
Short: EMA(close, ribbon lookback 8, T4, last completed bar) < EMA(close, ribbon lookback 8, T4, last completed bar)[2]