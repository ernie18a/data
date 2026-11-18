Calculation: Triple-HMA RSI = HMA(HMA(HMA(RSI(source, triple-HMA RSI lookback), triple-HMA smoothing lookback), triple-HMA smoothing lookback), triple-HMA smoothing lookback)
Calculation: Centered RMI = RMI(source, RMI smoothing lookback, RMI momentum lookback) - oscillator center
Calculation: Scaled triple-HMA RSI = (Triple-HMA RSI - oscillator center) * oscillator scale
Calculation: DEVWRSI = (EMA(EMA(VWMA(RSI(source, DEVWRSI lookback), DEVWRSI smoothing lookback), DEVWRSI smoothing lookback), DEVWRSI smoothing lookback) - oscillator center) * DEVWRSI scale
Calculation: TERSI = (EMA(EMA(EMA(RSI(source, TERSI lookback), TERSI smoothing lookback), TERSI smoothing lookback), TERSI smoothing lookback) - oscillator center) * oscillator scale
Calculation: RMI-HMA product = Triple-HMA RSI * Centered RMI / product divisor
Long: RMI-HMA product < RMI-HMA product buy threshold AND Centered RMI < RMI buy threshold AND TERSI < TERSI buy threshold AND DEVWRSI < DEVWRSI buy threshold AND Scaled triple-HMA RSI < triple-HMA RSI buy threshold AND CMO(source, CMO lookback) crosses above CMO buy threshold
Short: RMI-HMA product > RMI-HMA product sell threshold AND Centered RMI > RMI sell threshold AND TERSI > TERSI sell threshold AND DEVWRSI > DEVWRSI sell threshold AND Scaled triple-HMA RSI > triple-HMA RSI sell threshold AND CMO(source, CMO lookback) crosses below CMO sell threshold