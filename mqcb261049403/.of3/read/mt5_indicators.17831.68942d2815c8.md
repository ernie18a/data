Calculation: Lower threshold = MAX(close - ATR multiplier * ATR(ATR period), filter lookback bars including current bar)
Calculation: Upper threshold = MIN(close + ATR multiplier * ATR(ATR period), filter lookback bars including current bar)
Long: close > Upper threshold
Short: close < Lower threshold