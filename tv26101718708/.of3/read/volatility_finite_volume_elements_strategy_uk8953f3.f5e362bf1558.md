Calculation: movement = close - hl2 + hlc3 - hlc3[1]
Calculation: threshold = intra-volatility coefficient * stdev(log(high) - log(low), lookback) + inter-volatility coefficient * stdev(log(hlc3) - log(hlc3[1]), lookback)
Long: movement > threshold * close
Short: movement < -threshold * close