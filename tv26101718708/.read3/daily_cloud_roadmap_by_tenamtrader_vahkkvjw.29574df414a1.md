Calculation: T1 EMA(source, lookback) = EMA(source, lookback) computed on T1 bars with lookahead off and carried to chart bars; it uses the last completed T1 bar on historical chart bars and the T1 bar still forming on realtime chart bars
Calculation: Smoothed(x) = x when smoothing is disabled; otherwise EMA(EMA(x, smoothing lookback), smoothing lookback), calculated on chart bars
Long: Smoothed(T1 EMA(source, cloud 1 shorter lookback)) > Smoothed(T1 EMA(source, cloud 1 longer lookback))
Short: Smoothed(T1 EMA(source, cloud 1 shorter lookback)) <= Smoothed(T1 EMA(source, cloud 1 longer lookback))
Long: Smoothed(T1 EMA(source, cloud 2 shorter lookback)) > Smoothed(T1 EMA(source, cloud 2 longer lookback))
Short: Smoothed(T1 EMA(source, cloud 2 shorter lookback)) <= Smoothed(T1 EMA(source, cloud 2 longer lookback))
Long: Smoothed(T1 EMA(source, cloud 3 shorter lookback)) > Smoothed(T1 EMA(source, cloud 3 longer lookback))
Short: Smoothed(T1 EMA(source, cloud 3 shorter lookback)) <= Smoothed(T1 EMA(source, cloud 3 longer lookback))
Long: Smoothed(T1 EMA(source, cloud 4 shorter lookback)) > Smoothed(T1 EMA(source, cloud 4 longer lookback))
Short: Smoothed(T1 EMA(source, cloud 4 shorter lookback)) <= Smoothed(T1 EMA(source, cloud 4 longer lookback))
Long: Smoothed(T1 EMA(source, cloud 5 shorter lookback)) > Smoothed(T1 EMA(source, cloud 5 longer lookback))
Short: Smoothed(T1 EMA(source, cloud 5 shorter lookback)) <= Smoothed(T1 EMA(source, cloud 5 longer lookback))