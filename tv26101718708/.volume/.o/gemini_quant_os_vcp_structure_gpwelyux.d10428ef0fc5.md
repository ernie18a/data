Calculation: Tightening structure = at least the required number of confirmed pivot highs and lows; each newer high is lower than the next older high, and each newer low is higher than the next older low. Confirm pivots using equal left and right lookbacks.
Calculation: Range contraction = (highest high − lowest low over the shorter lookback) / (highest high − lowest low over the longer lookback) ≤ contraction threshold.
Calculation: ATR contraction = SMA of ATR over the shorter lookback / SMA of ATR over the longer lookback ≤ contraction threshold.
Calculation: Quiet volume = current volume ≤ SMA(volume, lookback) × quiet-volume factor.
Calculation: Breakout volume = current volume ≥ SMA(volume, same lookback) × breakout-volume factor.
Calculation: Break level = latest confirmed pivot high + (latest confirmed pivot high × buffer percentage).
Long: Tightening structure AND range contraction AND ATR contraction AND quiet volume AND breakout volume AND (close > break level OR high > break level, according to the selected breakout-price mode)