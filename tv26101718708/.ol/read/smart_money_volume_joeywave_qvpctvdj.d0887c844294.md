Calculation: BVC buy pressure = over the pressure lookback, sum(volume × buy fraction) / sum(volume), where buy fraction = 1 / (1 + exp(−1.7055 × z)), z = log(close / prior close) / standard deviation of log returns over the sigma window (buy fraction = 0.5 when the standard deviation is zero)
Long: BVC buy pressure >= 0.55
Short: BVC buy pressure <= 0.45