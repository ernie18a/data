Calculation: True Strength Index = 100 × EMA(EMA(change(higher-timeframe close), long smoothing length), short smoothing length) / EMA(EMA(abs(change(higher-timeframe close)), long smoothing length), short smoothing length); uses the higher-timeframe bar still forming (Pine v2 historical lookahead exposes its eventual close).
Calculation: TSI signal line = EMA(True Strength Index, signal length)
Calculation: RSI = RSI(higher-timeframe close)
Long: True Strength Index crosses above its signal line OR (True Strength Index > its signal line AND RSI > 50) OR RSI > 70
Short: True Strength Index crosses below its signal line OR (True Strength Index < its signal line AND RSI < 50) OR RSI < 30