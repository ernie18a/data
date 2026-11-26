Calculation: positive index = EMA(max(high - high[1], 0) / true range, lookback), where the numerator is zero unless it exceeds max(low[1] - low, 0), true range = max(high - low, abs(high - close[1]), abs(low - close[1])), and the ratio is zero when true range is zero
Calculation: negative index = EMA(max(low[1] - low, 0) / true range, same lookback), where the numerator is zero unless it exceeds max(high - high[1], 0), true range = max(high - low, abs(high - close[1]), abs(low - close[1])), and the ratio is zero when true range is zero
Long: positive index > negative index
Short: positive index < negative index
Long: on chart bars taking values calculated on T1 bars including the forming bar, positive index > negative index
Short: on chart bars taking values calculated on T1 bars including the forming bar, positive index < negative index