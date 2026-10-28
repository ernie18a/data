Calculation: Zero-Lag EMA = EMA(close + (close - close[floor((length - 1) / 2)]), length)
Long: close crosses above Zero-Lag EMA AND ADX > configured minimum AND (VWAP filter disabled OR close > VWAP)
Short: close crosses below Zero-Lag EMA AND ADX > configured minimum AND (VWAP filter disabled OR close < VWAP)