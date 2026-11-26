Calculation: normalized signed-volume ratio = SUM(volume * SIGN(CHANGE(price source)), OBV lookback) / SUM(volume, OBV lookback)
Long: EMA(normalized signed-volume ratio, shorter EMA lookback) crosses above EMA(normalized signed-volume ratio, longer EMA lookback)
Short: EMA(normalized signed-volume ratio, shorter EMA lookback) crosses below EMA(normalized signed-volume ratio, longer EMA lookback)