Calculation: RegressedDeviation = the OLS fitted value at x=lookback-1 for y[x] = close[x] - ((Highest(high, lookback)[x] + Lowest(low, lookback)[x])/2 + MA(selected price, lookback, smoothing method, smoothing phase)[x])/2, for x=0 through lookback-1
Long: RegressedDeviation(T1, still-forming bar) >= 0
Short: RegressedDeviation(T1, still-forming bar) < 0
Long: long-entry permission enabled AND RegressedDeviation(T1, signal-offset bar, forming if it is the current bar otherwise completed) > 0 AND RegressedDeviation(T1, bar immediately older than the signal-offset bar, completed) < 0
Short: short-entry permission enabled AND RegressedDeviation(T1, signal-offset bar, forming if it is the current bar otherwise completed) < 0 AND RegressedDeviation(T1, bar immediately older than the signal-offset bar, completed) > 0
Exit: long, long-exit permission enabled AND RegressedDeviation(T1, signal-offset bar, forming if it is the current bar otherwise completed) < 0
Exit: short, short-exit permission enabled AND RegressedDeviation(T1, signal-offset bar, forming if it is the current bar otherwise completed) > 0