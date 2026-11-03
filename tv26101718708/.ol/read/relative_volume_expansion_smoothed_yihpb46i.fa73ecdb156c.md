Calculation: Smoothed relative volume expansion = EMA(EMA(volume, shorter lookback) / EMA(volume, longer lookback), smoothing lookback)
Calculation: Signal line = EMA(smoothed relative volume expansion, lookback longer than the smoothing lookback)
Long: Smoothed relative volume expansion > signal line AND prior smoothed relative volume expansion <= prior signal line
Short: Smoothed relative volume expansion < signal line AND prior smoothed relative volume expansion >= prior signal line