Calculation: normalized value = x / (1 + absolute value of x)
Calculation: smoothed oscillator = ALMA of the oscillator, where the oscillator is 100 times [0.6 × normalized(20 × (ALMA(close) − VWMA(close)) / VWMA(close)) + 0.4 × normalized(ROC(close) / standard deviation of ROC(close) over 50 bars)], clamped to [−100, 100]; use the same ALMA settings for the ALMA of close and the final smoothing
Long: smoothed oscillator > 30 AND previous bar's smoothed oscillator ≤ 30
Short: smoothed oscillator < −30 AND previous bar's smoothed oscillator ≥ −30
Exit: long, smoothed oscillator < −10
Exit: short, smoothed oscillator > 0