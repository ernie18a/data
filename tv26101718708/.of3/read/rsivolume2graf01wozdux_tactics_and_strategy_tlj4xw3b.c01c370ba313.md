Calculation: Volume-weighted price = EMA(close * volume, len1) / EMA(volume, len1)
Long: RSI(close, len3) < 100 - uplimit
Short: RSI(close, len3) > uplimit OR RSI(Volume-weighted price, len1) <= urvol