Long: forming daily close > high of each of the two most recently completed daily bars
Short: forming daily close < low of each of the two most recently completed daily bars
Calculation: Long stop = signal daily close - (high of the most recently completed daily bar - high of the second most recently completed daily bar)
Calculation: Long target = signal daily close + (signal daily close - Long stop) * risk/reward ratio
Calculation: Short stop = signal daily close + (low of the most recently completed daily bar - low of the second most recently completed daily bar)
Calculation: Short target = signal daily close - (Short stop - signal daily close) * risk/reward ratio
Exit: Long, bar low <= Long stop OR bar high >= Long target
Exit: Short, bar high >= Short stop OR bar low <= Short target