Calculation: stochastic sum = SMA(Stochastic(close, high, low, shorter lookback), smoothing parameter) + SMA(Stochastic(close, high, low, longer lookback), smoothing parameter)
Calculation: trend state = 1 when stochastic sum > stochastic sum[1] AND VWMA(stochastic sum, lookback) > VWMA(stochastic sum, lookback)[1], -1 when stochastic sum < stochastic sum[1] AND VWMA(stochastic sum, lookback) < VWMA(stochastic sum, lookback)[1], otherwise 0
Long: trend state[1] = 0 AND trend state = 1
Exit: long, trend state[1] = 0 AND trend state = -1