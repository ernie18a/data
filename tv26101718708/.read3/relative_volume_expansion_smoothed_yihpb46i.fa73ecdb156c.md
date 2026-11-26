Calculation: Smoothed relative volume expansion = EMA(EMA(volume, shorter lookback) / EMA(volume, longer lookback), smoothing lookback)
Calculation: Relative volume signal = EMA(smoothed relative volume expansion, signal lookback)
Long: Smoothed relative volume expansion crosses above relative volume signal
Short: Smoothed relative volume expansion crosses below relative volume signal