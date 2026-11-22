Calculation: index drawdown = index close / highest(index close, drawdown lookback, T1, current completed bar) - 1
Calculation: latched GRIND bear = set when index drawdown reaches or falls below the drawdown trigger while CPI YoY from the last completed T2 bar exceeds the CPI gate; remain set until index drawdown rises above the trigger
Calculation: long target = chart close above SMA(close, longer lookback, T1, current completed bar sampled on chart bars) OR (NOT latched GRIND bear AND chart close above SMA(close, shorter lookback, T1, current completed bar sampled on chart bars))
Long: long target AND NOT long target[1]
Exit: long, NOT long target AND long target[1]
Calculation: QQQ drawdown from trailing peak = (QQQ close on T1 / highest(QQQ close on T1, peak lookback) - 1) × 100
Calculation: 200-SMA-only mode = set to CPI YoY on T2 > CPI gate when a bear latch starts; turn on if CPI YoY on T2 > CPI gate during an active bear latch; persist through bear-latch release; reset when the next bear latch starts; bear latch starts when QQQ drawdown <= drawdown trigger while no bear latch is active and ends when QQQ drawdown >= drawdown release
Long: chart instrument close > SMA(chart instrument close, slow SMA length) OR (200-SMA-only mode is false AND chart instrument close > SMA(chart instrument close, fast SMA length))
Exit: long, chart instrument close <= SMA(chart instrument close, slow SMA length) AND (200-SMA-only mode is true OR chart instrument close <= SMA(chart instrument close, fast SMA length))