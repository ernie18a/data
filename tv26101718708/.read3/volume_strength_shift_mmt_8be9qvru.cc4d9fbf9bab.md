Calculation: delta = volume * (2 * ((close - low) / (high - low)) - 1) when high > low, otherwise 0
Calculation: threshold = SMA(volume, smoothing lookback) * signal threshold multiplier
Long: delta > 0
Short: delta <= 0
Long: MA(delta, smoothing lookback, MA type) > 0
Short: MA(delta, smoothing lookback, MA type) <= 0
Long: MA(delta, smoothing lookback, MA type) > threshold
Short: MA(delta, smoothing lookback, MA type) < -threshold
Long: delta > delta[1] AND delta > 0
Short: delta < delta[1] AND delta < 0
Long: delta > delta[1] AND delta > 0 AND MA(delta, smoothing lookback, MA type) > threshold
Short: delta < delta[1] AND delta < 0 AND MA(delta, smoothing lookback, MA type) < -threshold
Long: MA(delta, smoothing lookback, MA type) > threshold AND NOT (MA(delta, smoothing lookback, MA type)[1] > threshold[1])
Short: MA(delta, smoothing lookback, MA type) < -threshold AND NOT (MA(delta, smoothing lookback, MA type)[1] < -threshold[1])