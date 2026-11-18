Calculation: adjusted PVT = offset parameter + scale parameter * PVT(OHLC4, volume / volume divisor)
Calculation: trend state = if adjusted PVT > SMA(adjusted PVT, lookback) then 1, else if adjusted PVT < SMA(adjusted PVT, lookback) then -1, else prior trend state, initially 0
Long: trend state = 1
Short: trend state = -1