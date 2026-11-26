Calculation: Smoothed price = selected moving average(applied price (selected price type), smoothing method, smoothing length, phase)
Calculation: Buy threshold = lowest((highest high(extremum lookback) + smoothed price) / 2, trail lookback)
Calculation: Sell threshold = highest((lowest low(extremum lookback) + smoothed price) / 2, trail lookback)
Long: Applied price > Buy threshold
Short: Applied price < Sell threshold
Long: On chart bars taking T1 indicator values, applied price on the still-forming T1 bar > Buy threshold on the still-forming T1 bar
Short: On chart bars taking T1 indicator values, applied price on the still-forming T1 bar < Sell threshold on the still-forming T1 bar