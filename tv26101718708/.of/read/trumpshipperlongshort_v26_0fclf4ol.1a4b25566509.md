Calculation: Daily return = (current daily close - previous daily close) / previous daily close, using the daily timeframe (higher than the chart timeframe); current daily bar, which may still be forming, and the previous completed daily bar.
Long: Daily return > threshold OR (Daily return >= -threshold AND Daily return <= threshold AND previous prediction was long)
Short: Daily return < -threshold OR (Daily return >= -threshold AND Daily return <= threshold AND previous prediction was short)
Exit: Short, Daily return > threshold OR (Daily return >= -threshold AND Daily return <= threshold AND previous prediction was long)
Exit: Long, Daily return < -threshold OR (Daily return >= -threshold AND Daily return <= threshold AND previous prediction was short)