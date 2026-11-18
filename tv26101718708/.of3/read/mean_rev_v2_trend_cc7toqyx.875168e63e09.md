Calculation: smoothed stochastic %K = SMA(Stochastic %K(high, low, close, stochastic lookback), K smoothing)
Calculation: smoothed stochastic %D = SMA(smoothed stochastic %K, D smoothing)
Calculation: fast moving average = EMA(close, fast lookback)
Calculation: slow moving average = SMA(close, slow lookback)
Calculation: average true range = ATR(ATR lookback)
Long: crossover(smoothed stochastic %K, smoothed stochastic %D) AND smoothed stochastic %K < oversold entry threshold AND fast moving average > slow moving average AND long trading enabled
Short: crossunder(smoothed stochastic %K, smoothed stochastic %D) AND smoothed stochastic %K > overbought entry threshold AND slow moving average > fast moving average AND short trading enabled
Exit: long, (crossunder(smoothed stochastic %K, smoothed stochastic %D) AND smoothed stochastic %K > overbought close threshold) OR (open < close - average true range * ATR modifier)
Exit: short, (crossover(smoothed stochastic %K, smoothed stochastic %D) AND smoothed stochastic %K < oversold close threshold) OR (open > close + average true range * ATR modifier)