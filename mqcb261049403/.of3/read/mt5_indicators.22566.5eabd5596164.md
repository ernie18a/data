Calculation: Trend = +1 when MovingAverage(close, smoothing method, phase, lookback) > MovingAverage(open, smoothing method, phase, lookback), -1 when <, otherwise its previous value (initially 0)
Long: Trend > 0 AND previous Trend <= 0
Short: Trend < 0 AND previous Trend >= 0
Long: On the first chart bar of each T1 period, Trend calculated from the current forming T1 bar > 0
Short: On the first chart bar of each T1 period, Trend calculated from the current forming T1 bar < 0