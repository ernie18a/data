Calculation: Typical price = (high + low + close) / 3
Calculation: Money flow = close - (high + low) / 2 + current-bar typical price - previous-bar typical price
Calculation: Cutoff = intrabar coefficient × standard deviation of log(high / low) + interbar coefficient × standard deviation of log(current-bar typical price / previous-bar typical price), using the same lookback for both standard deviations
Long: (money flow > cutoff × close AND reverse is disabled) OR (money flow < -cutoff × close AND reverse is enabled)
Short: (money flow < -cutoff × close AND reverse is disabled) OR (money flow > cutoff × close AND reverse is enabled)
Exit: long, (money flow < -cutoff × close AND reverse is disabled) OR (money flow > cutoff × close AND reverse is enabled)
Exit: short, (money flow > cutoff × close AND reverse is disabled) OR (money flow < -cutoff × close AND reverse is enabled)