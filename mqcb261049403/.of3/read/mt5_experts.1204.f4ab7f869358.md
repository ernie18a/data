Calculation: X2MA = second moving-average smoothing of the first moving-average smoothing of the applied price, with separate method, lookback, and phase parameters for each smoothing.
Long: X2MA > X2MA[1] on chart bars
Short: X2MA < X2MA[1] on chart bars
Long: On the configured completed-bar offset of T1 bars, the previous Parabolic SAR direction is bearish AND Parabolic SAR(high = X2MA(T1) + point size, low = X2MA(T1) - point size, bearish step, bearish maximum, bullish step, bullish maximum) <= X2MA(T1) + point size
Short: On the configured completed-bar offset of T1 bars, the previous Parabolic SAR direction is bullish AND Parabolic SAR(high = X2MA(T1) + point size, low = X2MA(T1) - point size, bearish step, bearish maximum, bullish step, bullish maximum) >= X2MA(T1) - point size
Exit: Long, low <= entry price - stop-loss distance in points × point size OR high >= entry price + take-profit distance in points × point size
Exit: Short, high >= entry price + stop-loss distance in points × point size OR low <= entry price - take-profit distance in points × point size