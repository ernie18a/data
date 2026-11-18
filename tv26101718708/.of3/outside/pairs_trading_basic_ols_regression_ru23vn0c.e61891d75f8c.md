Calculation: hedge-adjusted spread = SMA(IVI closing price, lookback length) - Correlation(SPY closing price, IVI closing price, lookback length) * Standard deviation(IVI closing price, lookback length) / Standard deviation(SPY closing price, lookback length) * SMA(SPY closing price, lookback length)
Long: Z-score(hedge-adjusted spread, lookback length) < long-entry threshold
Short: Z-score(hedge-adjusted spread, lookback length) > short-entry threshold
Exit: long, Z-score(hedge-adjusted spread, lookback length) > long-exit threshold
Exit: short, Z-score(hedge-adjusted spread, lookback length) < short-exit threshold