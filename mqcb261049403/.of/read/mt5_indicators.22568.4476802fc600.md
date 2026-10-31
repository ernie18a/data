Calculation: Smoothed candle = apply the same selected moving-average method, length, and other smoothing parameters separately to open and close; use the previous bar's smoothed close as the candle open when abs(open - close) <= a configurable price-distance threshold, otherwise use the current smoothed open. The candle close is the current smoothed close.
Calculation: Trend = 1 when the smoothed candle close > its open, -1 when the close < its open, and the previous trend when they are equal; initialize to 0.
Calculation: Higher-timeframe displayed trend = on the first chart bar of each higher-timeframe bar, evaluate the trend using that higher-timeframe bar while it is still forming; retain that value until the next higher-timeframe bar begins. Apply this independently to each configured higher timeframe.
Long: Chart-timeframe trend > 0 AND previous chart-timeframe trend <= 0
Short: Chart-timeframe trend < 0 AND previous chart-timeframe trend >= 0
Long: Higher-timeframe displayed trend > 0
Short: Higher-timeframe displayed trend < 0