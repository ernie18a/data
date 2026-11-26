Long: index close > SMA(index close, lookback)
Short: index close <= SMA(index close, lookback)
Long: flat position AND close > highest(high, breakout lookback)[1] AND ROC(close, momentum lookback) > momentum threshold
Calculation: trailing stop = max(prior trailing stop, highest high since entry × (1 − (index close > SMA(index close, lookback) ? initial stop percentage : tight stop percentage) / 100), initialized on entry using the entry bar's high and the same regime-selected percentage
Exit: long, close < trailing stop
Calculation: long stop = max(previous long stop, highest traded-instrument high since entry × (1 − (index close > SMA(index close, index average length) ? broad-index-up stop distance : broad-index-down stop distance) / 100)
Long: close > highest traded-instrument high over the prior breakout lookback bars AND ROC(traded-instrument close, momentum lookback) > momentum threshold
Exit: long, close < long stop