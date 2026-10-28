Calculation: Money flow = close − (high + low) / 2 + typical price − previous bar’s typical price, where typical price = (high + low + close) / 3
Calculation: Volatility cutoff = intra-bar coefficient × rolling standard deviation of log(high / low) + inter-bar coefficient × rolling standard deviation of log(typical price / previous bar’s typical price); both standard deviations use the same lookback
Long: Money flow > volatility cutoff × close
Short: Money flow < −volatility cutoff × close