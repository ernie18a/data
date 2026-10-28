Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: Williams value = 100 × (close − highest high over lookback) ÷ (highest high over lookback − lowest low over lookback)
Calculation: Smoothed Williams value = EMA(Williams value, lookback)
Calculation: Long stop = signal-bar close × (1 − stop-loss fraction)
Calculation: Short stop = signal-bar close × (1 + stop-loss fraction)
Long: Fast EMA >= Slow EMA OR (Fast EMA > Slow EMA AND close < Fast EMA) OR (Fast EMA > Slow EMA AND previous close < Fast EMA AND close > Fast EMA) OR (Fast EMA > Slow EMA AND low < Fast EMA AND previous low >= previous Fast EMA AND previous low > Fast EMA AND (classic EMA filter disabled OR close > classic EMA))
Short: Fast EMA < Slow EMA OR (Fast EMA < Slow EMA AND close > Fast EMA) OR (Fast EMA < Slow EMA AND previous close > Fast EMA AND close < Fast EMA) OR (Fast EMA < Slow EMA AND high > Fast EMA AND previous high <= previous Fast EMA AND previous high < Fast EMA AND (classic EMA filter disabled OR close < classic EMA))
Exit: Long, Fast EMA < Slow EMA OR (Smoothed Williams value > -20 AND Williams value > -20) OR close < Long stop
Exit: Short, Fast EMA > Slow EMA OR (Smoothed Williams value < -80 AND Williams value < -80) OR close > Short stop