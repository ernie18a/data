Calculation: Volume-weighted mean = sum(close[n] * volume[n], n = 0 to lookback - 1) / sum(volume[n], n = 0 to lookback - 1)
Calculation: Volume-weighted standard deviation = sqrt(sum((close[n] - volume-weighted mean)^2 * volume[n], n = 0 to lookback - 1) / ((count of nonzero volume[n], n = 0 to lookback - 1 - 1) * sum(volume[n], n = 0 to lookback - 1) / count of nonzero volume[n], n = 0 to lookback - 1))
Long: low <= volume-weighted mean - band multiplier * volume-weighted standard deviation
Short: high >= volume-weighted mean + band multiplier * volume-weighted standard deviation
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage)