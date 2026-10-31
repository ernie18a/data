Calculation: Average rise and average fall = over a lookback of consecutive changes in a selected OHLC-derived price, average the positive changes and the absolute values of the negative changes separately; ignore changes whose absolute value is at most twice double-precision machine epsilon, and use zero when a group is empty.
Calculation: Smoothed rise and smoothed fall = apply the same selected moving-average method, length, and other smoothing parameters separately to average rise and average fall.
Calculation: Higher-timeframe smoothed rise and fall = calculate the same series on a higher timeframe, using the bar still forming; sample them on the first chart bar of each higher-timeframe bar and retain those values until the next higher-timeframe bar.
Long: Chart-timeframe smoothed rise > chart-timeframe smoothed fall
Short: Chart-timeframe smoothed rise < chart-timeframe smoothed fall
Long: Higher-timeframe smoothed rise > higher-timeframe smoothed fall
Short: Higher-timeframe smoothed rise < higher-timeframe smoothed fall