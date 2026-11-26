Calculation: Blau Stochastic = if smoothed range ≠ 0 then 100 × smoothed(applied price − LLV(low, range lookback)) / smoothed(HHV(high, range lookback) − LLV(low, range lookback)) − 50, otherwise 0; each smoothed value is Smooth(series, lookback, smoothing method, phase), applied successively with the first, second, and signal smoothing lookbacks
Long: Blau Stochastic > 0
Short: Blau Stochastic < 0
Long: On each chart bar, Blau Stochastic on the current forming T1 bar containing that chart bar > 0
Short: On each chart bar, Blau Stochastic on the current forming T1 bar containing that chart bar < 0