Long: RSI(close, lookback, T1, forming bar) <= lower threshold
Short: RSI(close, lookback, T1, forming bar) >= upper threshold
Long: Stochastic %K(lookback, smoothing, slowing, T1, forming bar) <= lower threshold
Short: Stochastic %K(lookback, smoothing, slowing, T1, forming bar) >= upper threshold
Long: close > MA(applied price, lookback, T1, forming bar)
Short: close <= MA(applied price, lookback, T1, forming bar)
Long: MA(applied price, shorter lookback, T1, forming bar) >= MA(applied price, longer lookback, T2, forming bar) AND MA(applied price, shorter lookback, T1, previous completed bar) < MA(applied price, longer lookback, T2, previous completed bar)
Short: MA(applied price, shorter lookback, T1, forming bar) <= MA(applied price, longer lookback, T2, forming bar) AND MA(applied price, shorter lookback, T1, previous completed bar) > MA(applied price, longer lookback, T2, previous completed bar)