Calculation: Change = Zero-lag MA(applied price, smoothing method 1, lookback 1, phase 1, smoothing method 2, lookback 2, phase 2) - its value on the previous chart bar
Calculation: Deviation = population standard deviation(Change, deviation lookback including the current chart bar)
Long: Change > 0
Short: Change < 0
Long: Change > lower threshold multiplier × Deviation AND Change <= higher threshold multiplier × Deviation
Long: Change > higher threshold multiplier × Deviation
Short: Change < -lower threshold multiplier × Deviation AND Change >= -higher threshold multiplier × Deviation
Short: Change < -higher threshold multiplier × Deviation
Calculation: T1 change = Zero-lag MA(applied price, smoothing method 1, lookback 1, phase 1, smoothing method 2, lookback 2, phase 2, T1, current bar) - its value on the previous T1 bar; calculated on T1 bars, with the mapped value from the still-forming T1 bar copied to chart bars
Calculation: T1 deviation = population standard deviation(T1 change, deviation lookback including the current T1 bar)
Long: T1 change > 0 on chart bars using the mapped value from the still-forming T1 bar
Short: T1 change < 0 on chart bars using the mapped value from the still-forming T1 bar
Long: T1 change > lower threshold multiplier × T1 deviation AND T1 change <= higher threshold multiplier × T1 deviation on chart bars using the mapped value from the still-forming T1 bar
Long: T1 change > higher threshold multiplier × T1 deviation on chart bars using the mapped value from the still-forming T1 bar
Short: T1 change < -lower threshold multiplier × T1 deviation AND T1 change >= -higher threshold multiplier × T1 deviation on chart bars using the mapped value from the still-forming T1 bar
Short: T1 change < -higher threshold multiplier × T1 deviation on chart bars using the mapped value from the still-forming T1 bar