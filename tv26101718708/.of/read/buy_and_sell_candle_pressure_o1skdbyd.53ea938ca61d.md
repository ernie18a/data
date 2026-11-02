Calculation: Local bias trail = EMA, RMA, or SMA of close, HLC3, or OHLC4.
Calculation: Higher-timeframe bias trail = the same average and source calculated on a higher timeframe, then processed by the imported higher-timeframe sampler. The supplied code does not define the sampler or establish whether it returns the last completed bar or the bar still forming.
Calculation: Buy percentage, sell percentage, and normalized pressure = the imported candle-pressure calculation. Its formula is absent from the supplied code, so these values cannot be reproduced from the framework alone. The imported rounding calculation for buy percentage is also absent.
Long: Close > local bias trail.
Short: Close < local bias trail.
Long: Close > higher-timeframe bias trail.
Short: Close < higher-timeframe bias trail.
Long: Volume > 0 AND buy percentage > 50% AND sell percentage <= 50%.
Short: Volume > 0 AND sell percentage > 50%.
Long: Volume > 0 AND rounded buy percentage > 50%.
Short: Volume > 0 AND rounded buy percentage < 50%.