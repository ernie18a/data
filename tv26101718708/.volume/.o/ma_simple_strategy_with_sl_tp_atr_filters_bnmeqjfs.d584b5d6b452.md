Calculation: Four moving averages of close using the same selected type, with lookbacks ordered shortest to longest.
Calculation: ATR = average true range; volatility filter = current ATR compared with its longer-lookback simple moving average.
Calculation: Long stop price = entry price minus the selected stop distance; short stop price = entry price plus the selected stop distance. Stop distance is either a percentage of entry price or an ATR multiple using ATR captured at entry. If trailing is enabled, update the long stop from each bar’s high and retain the highest stop so far; update the short stop from each bar’s low and retain the lowest stop so far.
Calculation: Long take-profit price = entry close plus the selected target distance; short take-profit price = entry close minus the selected target distance. Target distance is either a percentage of entry close, an ATR multiple using ATR captured at entry, or the selected risk/reward multiple of the stop distance.
Long: Shortest MA >= next-shortest MA AND next-shortest MA >= next-longest MA AND next-longest MA >= longest MA AND (volatility filter disabled OR current ATR >= its longer-lookback simple moving average) AND within the configured date range.
Short: Shortest MA <= next-shortest MA AND next-shortest MA <= next-longest MA AND next-longest MA <= longest MA AND (volatility filter disabled OR current ATR >= its longer-lookback simple moving average) AND within the configured date range.
Exit: Long, previous bar had shortest MA >= next-shortest MA >= next-longest MA >= longest MA AND current bar does not have that ordering AND within the configured date range.
Exit: Short, previous bar had shortest MA <= next-shortest MA <= next-longest MA <= longest MA AND current bar does not have that ordering AND within the configured date range.
Exit: Long, low <= long stop price AND within the configured date range.
Exit: Long, high >= long take-profit price AND within the configured date range.
Exit: Short, high >= short stop price AND within the configured date range.
Exit: Short, low <= short take-profit price AND within the configured date range.