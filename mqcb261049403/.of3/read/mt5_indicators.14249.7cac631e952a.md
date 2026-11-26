Calculation: Chart upper channel = moving average(high, chart method, chart lookback, chart phase) + chart price shift in points
Calculation: Chart lower channel = moving average(low, chart method, chart lookback, chart phase) + chart price shift in points
Long: close > chart upper channel
Short: close < chart lower channel
Calculation: T1 upper channel = moving average(high, T1 method, T1 lookback, T1 phase, T1 still-forming bar) + T1 price shift in points
Calculation: T1 lower channel = moving average(low, T1 method, T1 lookback, T1 phase, T1 still-forming bar) + T1 price shift in points
Long: T1 close of the still-forming bar > T1 upper channel of the still-forming bar, sampled on chart bars
Short: T1 close of the still-forming bar < T1 lower channel of the still-forming bar, sampled on chart bars