Calculation: StructBull(high, low) = latest confirmed PivotHigh(high, swing length, swing length) > previous confirmed PivotHigh AND latest confirmed PivotLow(low, swing length, swing length) > previous confirmed PivotLow
Calculation: StructBear(high, low) = latest confirmed PivotHigh(high, swing length, swing length) < previous confirmed PivotHigh AND latest confirmed PivotLow(low, swing length, swing length) < previous confirmed PivotLow
Calculation: Flip(high, low) = (StructBull(high, low) AND StructBear(high, low)[1]) OR (StructBear(high, low) AND StructBull(high, low)[1])
Calculation: Swing(close) = abs(close - close[swing length])
Calculation: AtrRatio(high, low, close) = ATR(high, low, close, shorter ATR length) / SMA(ATR(high, low, close, shorter ATR length), longer ATR average length)
Calculation: Coil(high, low, close) = AtrRatio(high, low, close) <= coil threshold
Calculation: Score(high, low, close) = (1 if StructBull(high, low), -1 if StructBear(high, low), else 0) + (1 if Stochastic %K(close, high, low, range lookback) > range score upper level, -1 if Stochastic %K(close, high, low, range lookback) < range score lower level, else 0) + (1 if EMA(Swing(close), momentum smoothing) > momentum expansion factor * EMA(Swing(close)[swing length], momentum smoothing), -1 if EMA(Swing(close), momentum smoothing) < momentum contraction factor * EMA(Swing(close)[swing length], momentum smoothing), else 0) + (1 if AtrRatio(high, low, close) >= expansion threshold, else 0)
Long: Score(high, low, close) > 0 AND NOT Coil(high, low, close) AND NOT Flip(high, low)
Short: Score(high, low, close) < 0 AND NOT Coil(high, low, close) AND NOT Flip(high, low)
Long: Score(high, low, close) >= strong bias level AND Score(high, low, close)[1] < strong bias level
Short: Score(high, low, close) <= -strong bias level AND Score(high, low, close)[1] > -strong bias level
Long: StructBull(high, low)
Short: StructBear(high, low)
Long: Stochastic %K(close, high, low, range lookback) >= range marking upper level
Short: Stochastic %K(close, high, low, range lookback) <= range marking lower level
Long: [T1 values on chart bars, last completed bar] StructBull(high, low)
Short: [T1 values on chart bars, last completed bar] StructBear(high, low)
Long: [T1 values on chart bars, last completed bar] Stochastic %K(close, high, low, range lookback) >= range marking upper level
Short: [T1 values on chart bars, last completed bar] Stochastic %K(close, high, low, range lookback) <= range marking lower level
Long: [T1 values on chart bars, last completed bar] Score(high, low, close) > 0 AND NOT Coil(high, low, close)
Short: [T1 values on chart bars, last completed bar] Score(high, low, close) < 0 AND NOT Coil(high, low, close)