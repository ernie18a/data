Long: close > MA(close, lookback) AND +DI(lookback) >= -DI(lookback) AND close > ParabolicSAR(acceleration, maximum)
Short: close < MA(close, lookback) AND +DI(lookback) <= -DI(lookback) AND close < ParabolicSAR(acceleration, maximum)
Exit: long, close < ParabolicSAR(acceleration, maximum)
Exit: short, close > ParabolicSAR(acceleration, maximum)