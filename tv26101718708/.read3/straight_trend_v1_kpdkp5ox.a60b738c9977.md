Calculation: Channel reference = if close > Highest(open of the still-forming T1 bar sampled on chart bars, lookback chart bars) then Lowest(open of the still-forming T1 bar sampled on chart bars, lookback chart bars) else Highest(open of the still-forming T1 bar sampled on chart bars, lookback chart bars)
Long: close crosses above Channel reference
Short: close crosses below Channel reference
Exit: Long, high >= Channel reference * (1 + target 1 percentage / 100)
Exit: Long, high >= Channel reference * (1 + target 2 percentage / 100)
Exit: Long, high >= Channel reference * (1 + target 3 percentage / 100)
Exit: Short, low <= Channel reference * (1 - target 1 percentage / 100)
Exit: Short, low <= Channel reference * (1 - target 2 percentage / 100)
Exit: Short, low <= Channel reference * (1 - target 3 percentage / 100)