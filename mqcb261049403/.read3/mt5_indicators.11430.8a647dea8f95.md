Calculation: adaptive average = Kaufman Adaptive Moving Average(close, AMA lookback)
Calculation: weighted average = Weighted Moving Average(close, MA lookback)
Long: adaptive average[1] > weighted average[1] AND adaptive average < weighted average
Short: adaptive average[1] < weighted average[1] AND adaptive average > weighted average
Calculation: T1 adaptive average = Kaufman Adaptive Moving Average(close, AMA lookback, T1 bars, still-forming bar)
Calculation: T1 weighted average = Weighted Moving Average(close, MA lookback, T1 bars, still-forming bar)
Long: on chart bars using values from the T1 bar that contains each chart bar, T1 adaptive average[1] > T1 weighted average[1] AND T1 adaptive average < T1 weighted average
Short: on chart bars using values from the T1 bar that contains each chart bar, T1 adaptive average[1] < T1 weighted average[1] AND T1 adaptive average > T1 weighted average