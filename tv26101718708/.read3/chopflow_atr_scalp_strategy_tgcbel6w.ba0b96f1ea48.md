Long: datetime is within session AND Choppiness Index(high, low, close, lookback) < threshold AND OBV(close, volume) > EMA(OBV(close, volume), lookback)
Short: datetime is within session AND Choppiness Index(high, low, close, lookback) < threshold AND OBV(close, volume) < EMA(OBV(close, volume), lookback)
Exit: long, low <= close - ATR(lookback) * multiplier OR high >= entry price + ATR(lookback) * multiplier
Exit: short, high >= close + ATR(lookback) * multiplier OR low <= entry price - ATR(lookback) * multiplier