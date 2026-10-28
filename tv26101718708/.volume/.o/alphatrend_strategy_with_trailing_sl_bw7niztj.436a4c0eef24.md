Calculation: AlphaTrend = recursively, when MFI(hlc3, lookback) ≥ 50, the greater of the prior AlphaTrend and low − multiplier × SMA(true range, lookback); otherwise, the lesser of the prior AlphaTrend and high + multiplier × SMA(true range, lookback). The optional no-volume mode uses RSI(close, lookback) ≥ 50 instead of MFI.
Calculation: Long trailing stop = the greatest close-based stop since entering the long position: max(previous long trailing stop, close × (1 − trailing percentage)).
Calculation: Short trailing stop = the least close-based stop since entering the short position: min(previous short trailing stop, close × (1 + trailing percentage)).
Long: AlphaTrend crosses above its value 2 bars earlier.
Short: AlphaTrend crosses below its value 2 bars earlier.
Exit: Long, low ≤ long trailing stop.
Exit: Short, high ≥ short trailing stop.