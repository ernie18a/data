Calculation: Zero-lag moving average = 2 × first-stage moving average of the selected applied price − second-stage moving average of the first-stage average; the stages have independently configured smoothing methods and lookbacks. In the HTF variant, calculate from the higher timeframe’s still-forming bar and map to chart bars.
Calculation: One-bar change = current zero-lag moving average − previous zero-lag moving average.
Calculation: Change standard deviation = population standard deviation of consecutive one-bar changes over a configurable lookback.
Long: One-bar change > the smaller of the two volatility multipliers × change standard deviation
Short: One-bar change < −the smaller of the two volatility multipliers × change standard deviation