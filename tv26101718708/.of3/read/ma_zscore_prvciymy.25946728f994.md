Calculation: MA = selected EMA/SMA/DEMA/HMA/VWMA(price source, MA lookback)
Calculation: Z-score = (MA - EMA(MA, Z-score lookback)) / nz(StDev(MA, Z-score lookback), fallback parameter)
Calculation: Trend state = 1 if Z-score > bullish threshold AND NOT (Z-score < bearish threshold); -1 if Z-score < bearish threshold; otherwise prior trend state, initially 0
Long: Z-score > bullish threshold OR Trend state = 1
Short: Z-score < bearish threshold OR Trend state = -1