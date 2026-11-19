Calculation: trend baseline = EMA(SMA(close, trend length), trend length)
Calculation: liquidity range low = lowest(low - ATR(ATR length), range lookback)
Calculation: liquidity range high = highest(high + ATR(ATR length), range lookback)
Calculation: bin width = max(liquidity range high - liquidity range low, minimum positive range) / number of bins
Calculation: bin level(i) = liquidity range low + i * bin width
Calculation: node volume(i) = sum(volume[j] where abs(hl2[j] - bin level(i)) <= bin width / 2, j from current bar through range lookback bars ago)
Calculation: node share(i) = node volume(i) / maximum node volume across all bins
Calculation: POC index = index of maximum node volume across all bins
Long: trend line is shown AND close > trend baseline + ATR(ATR length)
Short: trend line is shown AND close < trend baseline - ATR(ATR length)
Long: trend baseline > trend baseline[status comparison lag]
Short: trend baseline <= trend baseline[status comparison lag]
Long: there exists a bin i where node share(i) > minimum relative volume threshold AND close > bin level(i) AND (POC highlighting is disabled OR i != POC index)
Short: there exists a bin i where node share(i) > minimum relative volume threshold AND close <= bin level(i) AND (POC highlighting is disabled OR i != POC index)