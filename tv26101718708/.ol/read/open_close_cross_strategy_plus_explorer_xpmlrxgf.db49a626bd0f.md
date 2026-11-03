Calculation: Selected moving average = apply the configured moving-average type and lookback separately to open and close bars on a higher timeframe; use the last completed higher-timeframe bar in non-repainting mode.
Calculation: ATR = average true range over its lookback on the chart timeframe.
Calculation: Long trailing stop = the highest value so far of close × (1 − trailing percentage) while long; reset when not long.
Calculation: Short trailing stop = the lowest value so far of close × (1 + trailing percentage) while short; reset when not short.
Long: Selected close moving average crosses above selected open moving average + ATR × multiplier OR the prior completed higher-timeframe selected close moving average > the prior completed higher-timeframe selected open moving average + higher-timeframe ATR × multiplier
Short: Selected close moving average crosses below selected open moving average − ATR × multiplier OR the prior completed higher-timeframe selected close moving average < the prior completed higher-timeframe selected open moving average − higher-timeframe ATR × multiplier
Exit: Long, short-entry condition when configured for long-only trading OR low ≤ long trailing stop when the long trailing percentage is nonzero
Exit: Short, long-entry condition when configured for short-only trading OR high ≥ short trailing stop when the short trailing percentage is nonzero