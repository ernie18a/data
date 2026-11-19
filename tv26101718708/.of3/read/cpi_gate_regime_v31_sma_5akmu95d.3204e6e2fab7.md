Calculation: index drawdown = index close / highest(index close, drawdown lookback, T1, current completed bar) - 1
Calculation: latched GRIND bear = set when index drawdown reaches or falls below the drawdown trigger while CPI YoY from the last completed T2 bar exceeds the CPI gate; remain set until index drawdown rises above the trigger
Calculation: long target = chart close above SMA(close, longer lookback, T1, current completed bar sampled on chart bars) OR (NOT latched GRIND bear AND chart close above SMA(close, shorter lookback, T1, current completed bar sampled on chart bars))
Long: long target AND NOT long target[1]
Exit: long, NOT long target AND long target[1]