Calculation: Smoothed open and smoothed close = apply the same selected moving-average method, length, and other smoothing parameters independently to open and close; supported methods are SMA, EMA, SMMA, LWMA, Jurik moving average, JurX, parabolic moving average, T3, VIDYA, and Kaufman adaptive moving average.
Calculation: Adjusted smoothed open = previous bar's smoothed close when abs(open - close) <= a price-distance threshold; otherwise the current bar's smoothed open.
Calculation: Trend = +1 when smoothed close > adjusted smoothed open, -1 when smoothed close < adjusted smoothed open, and the preceding trend when they are equal; initialize to 0.
Calculation: Higher-timeframe trend signal = calculate the same trend and its changes on the higher timeframe using the bar still forming; sample its signal on the first chart bar of each higher-timeframe bar and carry that signal forward through the remaining chart bars in that higher-timeframe bar.
Long: Chart-timeframe trend > 0 AND previous chart-timeframe trend <= 0
Long: Higher-timeframe trend signal > 0
Short: Chart-timeframe trend < 0 AND previous chart-timeframe trend >= 0
Short: Higher-timeframe trend signal < 0