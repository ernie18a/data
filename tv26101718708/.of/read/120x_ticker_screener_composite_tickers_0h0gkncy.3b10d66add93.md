Calculation: Higher-timeframe close = close of the higher-timeframe bar still forming, evaluated on each chart bar.
Calculation: Previous higher-timeframe close = the higher-timeframe close observed on the last chart bar before the current higher-timeframe bar began.
Calculation: Percentage change = higher-timeframe close divided by previous higher-timeframe close minus 1, expressed as a percentage and rounded to a configurable precision.
Calculation: Sampled SMA = on the first chart bar of each higher-timeframe period, store the higher-timeframe close; on that bar, average the latest lookback-length stored values. On other chart bars, average the current higher-timeframe close and the latest lookback-length minus one stored values.
Calculation: Sampled RMA = initialize with the sampled SMA; on each higher-timeframe period change, save the RMA from the preceding chart bar. On every chart bar, calculate current higher-timeframe close divided by the lookback length plus the saved RMA multiplied by one minus the reciprocal of the lookback length.
Calculation: Sampled RSI = calculate gain as max(higher-timeframe close minus previous higher-timeframe close, 0) and loss as max(previous higher-timeframe close minus higher-timeframe close, 0). Apply the same sampling and RMA procedure as sampled RMA independently to gain and loss, using the same lookback length as the sampled SMA and RMA; RSI = 100 - 100 / (1 + smoothed gain / smoothed loss).
Long: Percentage change > 0
Short: Percentage change < 0
Long: Higher-timeframe close > sampled SMA
Short: Higher-timeframe close < sampled SMA
Long: Higher-timeframe close > sampled RMA
Short: Higher-timeframe close < sampled RMA
Long: Sampled RSI < lower RSI threshold
Short: Sampled RSI > upper RSI threshold