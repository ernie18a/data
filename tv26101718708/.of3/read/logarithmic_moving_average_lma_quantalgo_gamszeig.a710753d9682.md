Calculation: LogWAvg = (SUM(close[i] / LN(MAX(i + log decay, 2))^2 for i = 0 to weight lookback - 1)) / (SUM(1 / LN(MAX(i + log decay, 2))^2 for i = 0 to weight lookback - 1))
Calculation: Momentum = SUM(LN(close / close[1]), weight lookback) * 252 / weight lookback
Calculation: Blend = ROC(LogWAvg, slope lookback) * (1 - blend weight + blend weight * CORREL(LN(close), bar number, weight lookback)^2)
Calculation: Score = Blend * IF(SIGN(Blend) = SIGN(Momentum) AND ABS(Momentum) > momentum floor, momentum multiplier, 1)
Calculation: SmoothScore = MA(Score, smoothing lookback, smoothing type)
Long: SmoothScore crosses above 0
Long: SmoothScore crosses above long threshold
Long: SmoothScore > 0
Long: SmoothScore > long threshold
Short: SmoothScore crosses below 0
Short: SmoothScore crosses below short threshold
Short: SmoothScore < 0
Short: SmoothScore < short threshold
Exit: long, SmoothScore crosses below long threshold
Exit: short, SmoothScore crosses above short threshold