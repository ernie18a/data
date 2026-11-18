Long: index close > SMA(index close, lookback)
Short: index close <= SMA(index close, lookback)
Long: flat position AND close > highest(high, breakout lookback)[1] AND ROC(close, momentum lookback) > momentum threshold
Calculation: trailing stop = max(prior trailing stop, highest high since entry × (1 − (index close > SMA(index close, lookback) ? initial stop percentage : tight stop percentage) / 100), initialized on entry using the entry bar's high and the same regime-selected percentage
Exit: long, close < trailing stop