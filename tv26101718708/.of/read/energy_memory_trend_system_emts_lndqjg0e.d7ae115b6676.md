Calculation: Directional memory = EMA(sqrt(ATR) × ln(volume + 1) × ROC(close))
Calculation: Upper and lower memory bands = SMA(directional memory) ± standard deviation(directional memory) × multiplier
Calculation: Trend state = bullish when directional memory is above its upper memory band; bearish when below its lower memory band; otherwise retain the previous state (initially neutral)
Long: Directional memory > upper memory band AND previous trend state is not bullish
Short: Directional memory < lower memory band AND previous trend state is not bearish