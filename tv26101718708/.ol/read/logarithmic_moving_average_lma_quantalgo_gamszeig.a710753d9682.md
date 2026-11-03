Calculation: Logarithmic moving average = sum of each close in the lookback multiplied by its weight, divided by the sum of the weights; the weight for lag i is 1 / ln(max(i + steepness, 2))².
Calculation: LMA slope = (current logarithmic moving average − its value 10 bars ago) / its value 10 bars ago × 100.
Calculation: Trend quality = the square of the Pearson correlation between lag index and the natural logarithm of close over the lookback, clamped to [0, 1].
Calculation: Log-return momentum = the sum of log(close / previous close) over the lookback × 252 / lookback.
Calculation: Smoothed signal = the selected moving average of signal over the smoothing lookback, where signal = LMA slope × (0.5 + 0.5 × trend quality), multiplied by the momentum weight when the signal and log-return momentum have the same sign and absolute momentum exceeds its threshold.
Long: Smoothed signal > 0 OR (smoothed signal > 0 and previous smoothed signal <= 0) OR (smoothed signal > long threshold and previous smoothed signal <= long threshold)
Short: Smoothed signal < 0 OR (smoothed signal < 0 and previous smoothed signal >= 0) OR (smoothed signal < short threshold and previous smoothed signal >= short threshold)
Exit: long, smoothed signal < long threshold and previous smoothed signal >= long threshold
Exit: short, smoothed signal > short threshold and previous smoothed signal <= short threshold