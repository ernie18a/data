Long: volatility close(T1, current bar, mapped to chart bars; fallback parameter if unavailable) > capitulation parameter
Long: flat AND volatility close(T1, current bar, mapped to chart bars; fallback parameter if unavailable) <= support parameter AND high >= highest(high[1], lookback parameter)
Short: flat AND volatility close(T1, current bar, mapped to chart bars; fallback parameter if unavailable) <= support parameter AND low <= lowest(low[1], lookback parameter)
Calculation: trailing distance = close × trail-percent parameter
Exit: Long, high >= entry price + trailing distance AND low <= highest high since activation − trailing distance
Exit: Short, low <= entry price − trailing distance AND high >= lowest low since activation + trailing distance
Long: ETH implied volatility close on T1, or fallback volatility value if unavailable, <= volatility threshold AND traded instrument high >= highest traded instrument high over the preceding lookback bars AND position size = 0
Short: ETH implied volatility close on T1, or fallback volatility value if unavailable, <= volatility threshold AND traded instrument low <= lowest traded instrument low over the preceding lookback bars AND position size = 0