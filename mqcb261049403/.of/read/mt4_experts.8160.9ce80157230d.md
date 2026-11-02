Calculation: Volatility quality increment = Let H, L, O and C be the same-method, same-length moving averages of high, low, open and close. Optionally replace C with the moving average of median price (high + low) / 2. Let P be C from a configurable number of bars earlier. The increment is abs(((C - P) / max(H - L, H - P, P - L) + (C - O) / (H - L)) / 2) * (C - P + C - O) / 2. Set the increment to zero if its absolute value is below an optional price-distance threshold. Calculate on the chart timeframe or a higher timeframe; for a higher timeframe use the bar still forming and map its value to chart bars.
Calculation: Volatility quality direction = The sign of the most recent nonzero volatility quality increment, carried forward through zero increments. Compare the direction on either the current chart bar or the last completed chart bar, selected consistently.
Long: Volatility quality direction > 0
Short: Volatility quality direction < 0
Exit: long, volatility quality direction < 0 AND previous chart bar's volatility quality direction > 0
Exit: short, volatility quality direction > 0 AND previous chart bar's volatility quality direction < 0
Exit: long, low <= entry price - enabled stop-loss distance OR high >= entry price + enabled take-profit distance
Exit: short, high >= entry price + enabled stop-loss distance OR low <= entry price - enabled take-profit distance