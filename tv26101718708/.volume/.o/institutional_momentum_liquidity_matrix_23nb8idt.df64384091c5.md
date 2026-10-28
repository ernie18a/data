Calculation: RSI-threshold price = Using the prior completed chart bar’s close C and Wilder RMAs U and D of positive and negative close changes over the RSI lookback N, let R = threshold / (100 − threshold). If R×D×(N−1) − U×(N−1) > 0, use C + R×D×(N−1) − U×(N−1); otherwise, if U×(N−1)/R − D×(N−1) > 0, use C − [U×(N−1)/R − D×(N−1)]; otherwise use C. Recalculate on each confirmed chart bar for the next bar’s upper and lower RSI thresholds.
Calculation: Current-period POC = The midpoint of the price bin with the greatest accumulated liquidity in the still-forming configured profile period (daily, weekly, monthly, or selected session). Aggregate lower-timeframe bars; use the selected measure (volume or absolute close−open change), divide each chart bar’s total measure equally among price bins touched by its high–low range, and use the configured bin count.
Calculation: POC proximity = POC exists AND absolute distance from the relevant RSI-threshold price to the current-period POC ≤ chart-timeframe ATR × configured proximity multiplier; if the proximity filter is disabled, this condition is true.
Calculation: Long stop = long entry price − chart-timeframe ATR at entry × configured stop multiplier.
Calculation: Long target = long entry price + (long entry price − long stop) × configured reward-to-risk ratio.
Calculation: Short stop = short entry price + chart-timeframe ATR at entry × configured stop multiplier.
Calculation: Short target = short entry price − (short stop − short entry price) × configured reward-to-risk ratio.
Long: Confirmed chart bar AND low ≤ lower RSI-threshold price AND POC proximity for the lower RSI-threshold price.
Short: Confirmed chart bar AND high ≥ upper RSI-threshold price AND POC proximity for the upper RSI-threshold price.
Exit: long, low ≤ long stop OR (low > long stop AND high ≥ long target)
Exit: short, high ≥ short stop OR (high < short stop AND low ≤ short target)