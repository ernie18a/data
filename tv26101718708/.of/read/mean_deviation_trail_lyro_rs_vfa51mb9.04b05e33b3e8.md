Calculation: Mean absolute deviation = average of |close on each bar in the lookback − the current bar’s EMA(close, mean lookback)|
Calculation: Smoothed normalized deviation = selected moving average of ((close − EMA(close, mean lookback)) / mean absolute deviation), with normalized deviation set to 0 when mean absolute deviation = 0
Long: current smoothed normalized deviation > 0 AND previous smoothed normalized deviation ≤ 0
Short: current smoothed normalized deviation ≤ 0 AND previous smoothed normalized deviation > 0