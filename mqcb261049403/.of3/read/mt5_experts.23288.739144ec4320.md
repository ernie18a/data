Long: high >= Highest(high, lookback, T1, current forming bar, sampled on chart bars) + offset
Short: low <= Lowest(low, lookback, T1, current forming bar, sampled on chart bars) - offset
Exit: Long, (stop-loss distance > 0 AND low <= entry price - stop-loss distance) OR (take-profit distance > 0 AND high >= entry price + take-profit distance)
Exit: Short, (stop-loss distance > 0 AND high >= entry price + stop-loss distance) OR (take-profit distance > 0 AND low <= entry price - take-profit distance)