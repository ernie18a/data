Long: close crosses above its simple moving average
Short: close crosses below its simple moving average
Calculation: Initial stop = entry bar low minus ATR times stop multiplier for longs; entry bar high plus ATR times stop multiplier for shorts
Calculation: Initial risk = absolute difference between entry price and initial stop
Calculation: Targets 1, 2, and 3 = entry price plus initial risk times each target multiplier for longs; entry price minus initial risk times each target multiplier for shorts
Calculation: Working stop = entry price after Target 1 is reached if breakeven is enabled; otherwise initial stop
Exit: Long, after the entry bar, high >= Target 3 OR (low <= working stop AND high < Target 3)
Exit: Short, after the entry bar, low <= Target 3 OR (high >= working stop AND low > Target 3)