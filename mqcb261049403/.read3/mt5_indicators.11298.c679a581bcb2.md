Calculation: momentum = Momentum(applied price, momentum lookback)
Calculation: threshold = coefficient * moving average(abs(momentum), averaging lookback, selected smoothing method, phase parameter)
Long: momentum > threshold
Short: momentum < -threshold