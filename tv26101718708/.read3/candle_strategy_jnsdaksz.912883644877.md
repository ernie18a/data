Long: On chart bar P of each session, long direction is enabled AND close > high of the session’s first chart bar
Short: On chart bar P of each session, short direction is enabled AND close < low of the session’s first chart bar
Exit: Long, low <= min(low[1], lowest(low, chart bars from the session’s first bar through the entry bar)), with the stop fixed at entry OR the current bar is the session’s last bar
Exit: Short, high >= max(high[1], highest(high, chart bars from the session’s first bar through the entry bar)), with the stop fixed at entry OR the current bar is the session’s last bar