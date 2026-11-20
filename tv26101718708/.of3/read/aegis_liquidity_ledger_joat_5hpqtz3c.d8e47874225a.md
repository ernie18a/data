Calculation: composite pressure = average(ROC(close, shortest lookback), ROC(close, next-shortest lookback), ROC(close, next-longest lookback), ROC(close, longest lookback))
Calculation: smoothed pressure = EMA(composite pressure, smoothing lookback)
Calculation: expansion threshold = max(STDEV(smoothed pressure, volatility lookback), minimum tick) × expansion multiplier
Long: smoothed pressure > 0
Long: bar confirmed AND smoothed pressure crosses above expansion threshold
Long: bar confirmed AND smoothed pressure crosses above zero
Short: smoothed pressure < 0
Short: bar confirmed AND smoothed pressure crosses below negative expansion threshold
Short: bar confirmed AND smoothed pressure crosses below zero