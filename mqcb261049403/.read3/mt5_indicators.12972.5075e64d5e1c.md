Calculation: Tick size = (high - low) / selected volume, or 1 if the quotient is zero
Calculation: Swing = ((high - low) + abs(open - close)) / (2 * Tick size)
Calculation: Bull measure = if open > close then (open - close) / Tick size + Swing else Swing
Calculation: Bear measure = if open < close then -(open - close) / Tick size + Swing else Swing
Calculation: Smoothed bull = moving average(Bull measure, method, phase, lookback)
Calculation: Smoothed bear = moving average(Bear measure, same method, same phase, same lookback)
Long: Smoothed bull crosses above Smoothed bear
Short: Smoothed bull crosses below Smoothed bear