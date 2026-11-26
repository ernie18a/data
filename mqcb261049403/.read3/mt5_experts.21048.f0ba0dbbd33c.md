Calculation: C = UltraAbsolutelyNoLagLwma(averaging method, starting lookback, averaging phase, period increment, period count, smoothing method, smoothing lookback, smoothing phase, upper threshold, lower threshold), calculated on T1 bars ([0] is the bar still forming; [1] is the last completed bar)
Long: C[1] is green AND C[0] is red
Short: C[1] is red AND C[0] is green
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance