Calculation: prior-day high = high(T1, last completed bar)
Calculation: prior-day low = low(T1, last completed bar)
Calculation: premarket high = highest(high, chart bars in the most recently completed premarket session)
Calculation: premarket low = lowest(low, chart bars in the most recently completed premarket session)
Long: close >= prior-day high AND close >= premarket high
Short: close <= prior-day low AND close <= premarket low