Calculation: Smoothed volume power = the selected moving average of the rolling Wilder RMA of the scaled bar metric. The bar metric is (close − open) / (high − low), or 0 when high = low, multiplied by (volume^(1 − volume boost) × volume factor + 1 − volume factor), using 0 for volume when volume ≤ 0. Scale it by dividing by the Wilder RMA of its absolute value over the scaling-days lookback (converted to chart-timeframe bars), multiplying by 100, and clamping to [−100, 100]; if the scaler is 0, use the bar metric × 100 before clamping.
Long: Smoothed volume power ≥ power threshold AND RSI ≥ RSI midline
Long: Smoothed volume power ≥ power threshold AND RSI < RSI midline AND previous bar's smoothed volume power < power threshold
Long: RSI ≥ RSI midline AND smoothed volume power < power threshold AND previous bar's RSI < RSI midline
Short: Smoothed volume power ≤ weakness threshold AND RSI < RSI midline
Short: Smoothed volume power ≤ weakness threshold AND RSI ≥ RSI midline AND previous bar's smoothed volume power > weakness threshold
Short: RSI < RSI midline AND smoothed volume power > weakness threshold AND previous bar's RSI ≥ RSI midline
Exit: Long, previous bar had smoothed volume power ≥ power threshold AND RSI ≥ RSI midline AND current bar has smoothed volume power < power threshold OR RSI < RSI midline
Exit: Short, previous bar had smoothed volume power ≤ weakness threshold AND RSI < RSI midline AND current bar has smoothed volume power > weakness threshold OR RSI ≥ RSI midline