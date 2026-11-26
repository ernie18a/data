Calculation: Smoothed range = smooth(high − low, smoothing method, smoothing lookback, phase) on T1 bars
Calculation: Chaikin stochastic = 100 × LWMA((Smoothed range − lowest(Smoothed range, stochastic lookback)) / (highest(Smoothed range, stochastic lookback) − lowest(Smoothed range, stochastic lookback)), weighted lookback) on T1 bars; [0] is still forming
Long: Chaikin stochastic[1] > Chaikin stochastic[2] AND Chaikin stochastic[0] < Chaikin stochastic[1]
Short: Chaikin stochastic[1] < Chaikin stochastic[2] AND Chaikin stochastic[0] > Chaikin stochastic[1]
Exit: Long, low ≤ entry price − stop-loss distance OR high ≥ entry price + take-profit distance
Exit: Short, high ≥ entry price + stop-loss distance OR low ≤ entry price − take-profit distance