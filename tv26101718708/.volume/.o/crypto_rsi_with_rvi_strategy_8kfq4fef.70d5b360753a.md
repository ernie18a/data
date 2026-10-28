Calculation: Volume-weighted RSI = 100 × Wilder-average(length, max(change in close, 0) × volume) ÷ [Wilder-average(length, max(change in close, 0) × volume) + Wilder-average(length, max(−change in close, 0) × volume)]
Calculation: RVI = 100 × Wilder-average(14, upward movement) ÷ [Wilder-average(14, upward movement) + Wilder-average(14, downward movement)], where upward movement is the close-price standard deviation over the same lookback as the Volume-weighted RSI when close rises, otherwise 0; downward movement is that standard deviation when close does not rise, otherwise 0
Calculation: RVI state = −1 when RVI < lower threshold; +1 when RVI > upper threshold; otherwise retain the previous state
Long: Volume-weighted RSI crosses above the upper threshold AND RVI state = +1
Short: Volume-weighted RSI crosses below the lower threshold AND RVI state = −1
Exit: long, Volume-weighted RSI crosses below the lower threshold AND RVI state = −1 OR low reaches the stop-loss level OR high reaches the take-profit level
Exit: short, high reaches the stop-loss level OR low reaches the take-profit level