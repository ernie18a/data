Calculation: Smoothed RSI = EMA(RSI(applied price, RSI lookback), RSI smoothing lookback)
Calculation: QQE range = EMA(EMA(abs(Smoothed RSI - Smoothed RSI[1]), RSI lookback), RSI lookback)
Calculation: QQE trailing level(x, d)[i] = x[i] + d[i] if x[i] < level[i-1] and not (x[i-1] < level[i-1] and x[i] + d[i] > level[i-1]); x[i] - d[i] if x[i] > level[i-1] and not (x[i-1] > level[i-1] and x[i] - d[i] < level[i-1]); otherwise level[i-1]
Calculation: Fast QQE level = QQE trailing level(Smoothed RSI, QQE range * smaller fast multiplier)
Calculation: Slow QQE level = QQE trailing level(Smoothed RSI, QQE range * larger slow multiplier)
Calculation: QQE direction state = bullish when Smoothed RSI > Fast QQE level AND Smoothed RSI > Slow QQE level; bearish when Smoothed RSI < Fast QQE level AND Smoothed RSI < Slow QQE level; otherwise previous state (initially neutral)
Long: QQE direction state = bullish
Short: QQE direction state = bearish