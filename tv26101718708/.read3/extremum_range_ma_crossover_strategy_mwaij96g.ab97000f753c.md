Calculation: MA = selected moving average(selected price source, MA length, MA type)
Calculation: rolling low = Lowest(low, lookback period)
Calculation: rolling high = Highest(high, lookback period)
Long: rolling low crosses above MA
Short: rolling high crosses below MA
Exit: long, close < rolling low
Exit: short, close > rolling high