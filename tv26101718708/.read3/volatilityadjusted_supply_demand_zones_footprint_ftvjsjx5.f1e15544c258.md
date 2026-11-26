Calculation: Displacement ratio = ABS(close - open) / ATR(atr length)
Calculation: Zone height = zone width multiplier * ATR(atr length)
Long: close[confirmation bars] > open[confirmation bars] AND Displacement ratio[confirmation bars] > displacement multiplier AND LOWEST(low, confirmation bars) >= high[confirmation bars] - Zone height[confirmation bars]
Short: close[confirmation bars] < open[confirmation bars] AND Displacement ratio[confirmation bars] > displacement multiplier AND HIGHEST(high, confirmation bars) <= low[confirmation bars] + Zone height[confirmation bars]