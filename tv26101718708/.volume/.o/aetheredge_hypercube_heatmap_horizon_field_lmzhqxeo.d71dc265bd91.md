Calculation: Standardized momentum = clamp((close − close from a longer lookback) / ATR, −4, 4).
Calculation: Standardized volatility = clamp(standard deviation of close changes over a lookback / ATR, −4, 4).
Calculation: Standardized volume surprise = clamp((volume − its moving average) / its standard deviation, −4, 4).
Calculation: Standardized trend = clamp((shorter-lookback EMA of close − longer-lookback EMA of close) / ATR, −4, 4).
Calculation: Standardized RSI = clamp(2 × (RSI − 50) / 50, −4, 4).
Calculation: Feature attention weight = exp(abs(standardized feature) / shared temperature) divided by the sum of that quantity across the five standardized features.
Calculation: Directional bias = attention-weighted sum of standardized momentum, standardized trend, and standardized RSI.
Long: Directional bias > 0
Short: Directional bias < 0