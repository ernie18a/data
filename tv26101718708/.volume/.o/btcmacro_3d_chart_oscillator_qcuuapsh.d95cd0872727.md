Calculation: Composite oscillator = weighted sum of rolling z-scores of: the ratio of twice the shorter price SMA to the longer price SMA, minus one; close-based MVRV, NUPL, Puell, stock-to-flow, and risk-wave source series; the difference between log close and its rolling linear regression; close divided by the M2 source series; the ISM source series; and the rate of change of volume. All source series default to close.
Calculation: Smoothed composite oscillator = EMA of the composite oscillator.
Calculation: Overheated level = long-lookback SMA of the smoothed composite oscillator + 1.5 times its long-lookback standard deviation.
Long: Smoothed composite oscillator < 0
Short: Smoothed composite oscillator > overheated level