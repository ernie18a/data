Calculation: Initial risk distance = initial stop ATR multiple × ATR of the last completed aggregated bar
Calculation: Initial stop = entry price − initial risk distance
Calculation: One R price = entry price + initial risk distance
Calculation: Highest high = highest high of completed aggregated bars since entry
Calculation: Active stop = initial stop; after a completed bar closes at or above the One R price, set it to the maximum of its previous value, entry price, and highest high − trailing ATR multiple × ATR of the last completed aggregated bar
Long: Position is flat AND (at a new completed aggregated bar, its close > its EMA, its RSI is between 50 and 70 inclusive, and its volume > its volume SMA; OR on the current forming aggregated bar, its close > its EMA, its RSI is between 50 and 70 inclusive, and its volume > its volume SMA)
Short: At a new completed aggregated bar, its close < its EMA, its RSI is between 30 and 50 inclusive, and its volume > its volume SMA
Exit: Long, at a new completed aggregated bar, its low ≤ active stop