Calculation: spread = DEMA(close, DEMA lookback, T1)[1] - DEMA(close, DEMA lookback, T1)[2], evaluated on T1 bars and sampled on chart bars using the last and second-last completed T1 bars
Calculation: shorter EMA = EMA(spread, shorter EMA lookback) on chart bars
Calculation: longer EMA = EMA(spread, longer EMA lookback) on chart bars
Calculation: smoothed stochastic %K = SMA(Stochastic(close, high, low, stochastic lookback), %K smoothing lookback)
Calculation: smoothed stochastic %D = SMA(smoothed stochastic %K, %D smoothing lookback)
Long: shorter EMA crosses above longer EMA
Short: shorter EMA crosses below longer EMA
Long: shorter EMA > longer EMA
Short: shorter EMA < longer EMA
Long: shorter EMA > longer EMA AND smoothed stochastic %K <= oversold threshold AND smoothed stochastic %K crosses above smoothed stochastic %D
Short: shorter EMA < longer EMA AND smoothed stochastic %K >= overbought threshold AND smoothed stochastic %K crosses below smoothed stochastic %D
Long: smoothed stochastic %K crosses above smoothed stochastic %D
Short: smoothed stochastic %K crosses below smoothed stochastic %D