Calculation: SupertrendDirection = Supertrend direction(Supertrend factor, Supertrend length)
Calculation: LastReversal(close) = sign(close - close[1]) if sign(close - close[1]) != 0 AND sign(close - close[1]) != sign(close[1] - close[2]), otherwise LastReversal[1]
Calculation: WeisWaveTrend(close, smoothing length) = LastReversal(close) if LastReversal(close) != WeisWaveTrend[1] AND (Rising(close, smoothing length) OR Falling(close, smoothing length)), otherwise WeisWaveTrend[1]
Long: SupertrendDirection[1] < SupertrendDirection[2]
Short: SupertrendDirection[1] > SupertrendDirection[2]
Long: SupertrendDirection[1] < 0
Short: SupertrendDirection[1] > 0
Long: WeisWaveTrend[1] > WeisWaveTrend[2]
Short: WeisWaveTrend[1] < WeisWaveTrend[2]
Long: WeisWaveTrend[1] > 0
Short: WeisWaveTrend[1] < 0
Long: close > open
Short: close <= open