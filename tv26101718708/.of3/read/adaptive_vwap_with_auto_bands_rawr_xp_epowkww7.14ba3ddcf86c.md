Calculation: normalized volatility = ATR(ATR lookback) / SMA(close, volatility lookback)
Calculation: adaptive multiplier = normalized volatility < lower volatility threshold ? low-volatility multiplier : normalized volatility > upper volatility threshold ? high-volatility multiplier : normal-volatility multiplier
Long: close < VWAP - adaptive multiplier * ATR(ATR lookback)
Short: close > VWAP + adaptive multiplier * ATR(ATR lookback)