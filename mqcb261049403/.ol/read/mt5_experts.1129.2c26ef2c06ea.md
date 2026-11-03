Calculation: Directional state = the sign of the sum of two comparisons: short-lookback moving average versus long-lookback moving average, and short-lookback RSI versus long-lookback RSI; each comparison contributes +1 when the short-lookback value is higher, −1 when lower, and 0 when equal. Use the configured applied prices and the configured signal timeframe, which may be higher or lower than the chart timeframe; evaluate completed bars.
Long: Current completed signal-timeframe directional state > 0
Short: Current completed signal-timeframe directional state < 0
Exit: Long, current completed signal-timeframe directional state < 0
Exit: Short, current completed signal-timeframe directional state > 0