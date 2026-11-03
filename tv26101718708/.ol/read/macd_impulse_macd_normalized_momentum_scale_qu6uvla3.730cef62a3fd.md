Calculation: Impulse MACD = zero-lag EMA of HLC3 minus RMA of high when above the RMA of high, minus RMA of low when below the RMA of low, otherwise zero; zero-lag EMA = 2 × EMA(HLC3, length) − EMA(EMA(HLC3, length), length)
Calculation: Impulse MACD signal = SMA(Impulse MACD, shorter lookback)
Calculation: Higher-timeframe MACD histogram = MACD − MACD signal, calculated on the next higher timeframe using its still-forming bar
Long: MACD > MACD signal OR Impulse MACD > Impulse MACD signal OR higher-timeframe MACD histogram > 0
Short: MACD < MACD signal OR Impulse MACD < Impulse MACD signal OR higher-timeframe MACD histogram < 0