Calculation: Regression close = rolling linear regression of close over a lookback, evaluated at the current bar; use raw close if regression candles are disabled
Calculation: Signal average = SMA or EMA of regression close over a separate lookback
Long: Close crosses above Signal average
Short: Close crosses below Signal average
Exit: Short, Close crosses above Signal average
Exit: Long, Close crosses below Signal average