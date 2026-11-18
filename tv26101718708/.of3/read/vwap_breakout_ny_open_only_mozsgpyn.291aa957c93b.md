Calculation: T1-anchored VWAP = VWAP(hlc3, reset at each T1 boundary, calculated on chart bars through the forming T1 period)
Long: during the configured New York session AND daily entry count is below the daily entry limit AND close < T1-anchored VWAP AND close crosses above VWAP(hlc3)
Short: during the configured New York session AND daily entry count is below the daily entry limit AND close > T1-anchored VWAP AND close crosses below VWAP(hlc3)
Exit: long, low <= VWAP(hlc3) on the entry-signal bar - stop-distance parameter OR high >= T1-anchored VWAP on the entry-signal bar
Exit: short, high >= VWAP(hlc3) on the entry-signal bar + stop-distance parameter OR low <= T1-anchored VWAP on the entry-signal bar