Calculation: Higher-timeframe deviation = close of the still-forming higher-timeframe bar minus its moving average of an applied price.
Calculation: Higher-timeframe normalization level = the zero-based element at index floor(lookback length × percentile) of the ascending sorted absolute deviations over the lookback, including the still-forming higher-timeframe bar.
Long: Higher-timeframe normalization level = 0 OR higher-timeframe deviation >= 0
Short: Higher-timeframe normalization level > 0 AND higher-timeframe deviation < 0