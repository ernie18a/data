Calculation: StochasticSignal = Stochastic signal line(K lookback, D lookback, slowing, smoothing method, price field; on chart bars, current forming bar)
Calculation: WilliamsPercentR = Williams %R(lookback, on chart bars, last completed bar)
Long: StochasticSignal < long stochastic threshold AND WilliamsPercentR < long Williams %R threshold
Short: StochasticSignal > short stochastic threshold AND WilliamsPercentR > short Williams %R threshold