Calculation: Smoothed oscillator = ALMA of the score clamped to [-100, 100], where score = 0.6 × normalize(20 × (short-term ALMA(close) − long-term VWMA(close)) / long-term VWMA(close)) + 0.4 × normalize(ROC(close, short lookback) / standard deviation of that ROC over a longer lookback); normalize(x) = x / (1 + abs(x)). Use the same ALMA parameters for trend and smoothing.
Long: Smoothed oscillator > 30 AND prior chart bar's smoothed oscillator ≤ 30
Short: Smoothed oscillator < −30 AND prior chart bar's smoothed oscillator ≥ −30
Exit: long, Smoothed oscillator < −10
Exit: short, Smoothed oscillator > 0
Exit: long or short, datetime > end-date parameter