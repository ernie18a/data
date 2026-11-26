Calculation: Delta = on each chart bar, sum the volume of its T1 bars when close > open, minus the volume when close < open, or zero when equal; if no T1 bars are available, use chart-bar volume with the same sign rule (T1 bars may still be forming)
Calculation: HA-CVD = on chart bars, CVD close is Delta at each enabled T2 reset boundary in America/New_York, otherwise prior CVD close + Delta; CVD open is zero at an enabled reset boundary, otherwise prior CVD close (or current CVD close on the first bar); CVD high/low are CVD open plus the maximum/minimum running sum of signed T1 volume within the chart bar (or the maximum/minimum of zero and Delta if T1 data is unavailable); HA-CVD close = (CVD open + CVD high + CVD low + CVD close) / 4; HA-CVD open is CVD open on the first bar, otherwise (prior HA-CVD open + prior HA-CVD close) / 2; HA-CVD high/low are the maximum/minimum of CVD high/low, HA-CVD open, and HA-CVD close (T1 bars may still be forming)
Long: HA-CVD close crosses above zero
Short: HA-CVD close crosses below zero
Long: HA-CVD close >= HA-CVD open AND NOT (HA-CVD low = HA-CVD open AND close < open)
Short: HA-CVD close < HA-CVD open AND NOT (HA-CVD high = HA-CVD open AND close > open)
Long: Delta > SMA(abs(Delta), spike lookback) × spike multiplier
Short: Delta < −(SMA(abs(Delta), spike lookback) × spike multiplier)
Long: EMA(HA-CVD close, shorter lookback) > EMA(HA-CVD close, longer lookback)
Short: EMA(HA-CVD close, shorter lookback) <= EMA(HA-CVD close, longer lookback)