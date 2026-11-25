Calculation: Up count = number of lookbacks from start lookback through start lookback + step × instance count, inclusive in step increments, for which JMA(close, lookback, phase) > JMA(close, lookback, phase)[1]
Calculation: Down count = number of those lookbacks for which JMA(close, lookback, phase) <= JMA(close, lookback, phase)[1]
Long: JMA(Up count, smoothing lookback, phase) > JMA(Down count, smoothing lookback, phase)
Short: JMA(Up count, smoothing lookback, phase) <= JMA(Down count, smoothing lookback, phase)