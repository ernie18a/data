Long: Within the configured trading session AND fewer than the daily limit of closed trades have occurred AND close < weekly anchored VWAP AND close > VWAP AND prior close <= prior VWAP
Short: Within the configured trading session AND fewer than the daily limit of closed trades have occurred AND close > weekly anchored VWAP AND close < VWAP AND prior close >= prior VWAP
Exit: Long, low <= entry-bar VWAP minus the configured stop distance OR high >= entry-bar weekly anchored VWAP
Exit: Short, high >= entry-bar VWAP plus the configured stop distance OR low <= entry-bar weekly anchored VWAP