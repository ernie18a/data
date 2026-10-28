Calculation: Stoch RSI = stochastic of RSI, with the stochastic value smoothed by a K-length simple moving average and then by a D-length simple moving average; both lengths are independent parameters
Long: Stoch RSI < long threshold AND MFI < long threshold AND close < EMA
Short: Stoch RSI > short threshold AND MFI > short threshold AND close > EMA
Exit: long, low <= entry price − long stop distance in minticks OR high >= entry price + long profit distance in minticks OR Stoch RSI > short threshold AND MFI > short threshold AND close > EMA
Exit: short, high >= entry price + short stop distance in minticks OR low <= entry price − short profit distance in minticks OR Stoch RSI < long threshold AND MFI < long threshold AND close < EMA