Calculation: Selected feature = one of stochastic %K, RSI, MFI, volume, z-score ((source − moving average) / standard deviation), close minus EMA, or close minus SMA
Calculation: Class label = one of: close > open; high − open > open − low; or high − open > ATR or open − low < ATR
Calculation: Feature vote = 1 if matching training cases labeled 1 outnumber matching cases labeled 0, otherwise 0; match when the training feature is within the selected tolerance of the current feature. For the first feature, also require the training feature > 0. Use prior-bar feature values paired with class labels, over the training lookback; omit the final row after shuffling.
Calculation: Model vote = 1 if the two feature votes’ matching-case counts, summed across both features, have more class-1 than class-0 cases; otherwise 0
Long: Model vote = 1
Short: Model vote = 0