Calculation: Working-bar values = OHLC and moving average on the chart timeframe or a selected higher or lower timeframe; use the bar still forming for current values and the preceding completed bar for previous values.
Calculation: Lower boundary = moving average minus channel distance.
Calculation: Upper boundary = moving average plus channel distance.
Calculation: Long trailing stop = the greater of the initial stop and the highest price reached since entry minus the trailing distance, once price has risen more than the trailing distance above entry.
Calculation: Short trailing stop = the lesser of the initial stop and the lowest price reached since entry plus the trailing distance, once price has fallen more than the trailing distance below entry.
Long: No open position AND previous low > previous lower boundary AND current low <= current lower boundary AND current close = current low AND (trade-time filter disabled OR current time is within the configured trading interval).
Short: No open position AND previous high < previous upper boundary AND current high >= current upper boundary AND current close = current high AND (trade-time filter disabled OR current time is within the configured trading interval).
Long: Step Down enabled AND position is long AND current price <= lowest long entry price minus grid distance.
Short: Step Down enabled AND position is short AND current price >= highest short entry price plus grid distance.
Long: Turn enabled AND position is short AND current price >= short entry price plus Turn distance.
Short: Turn enabled AND position is long AND current price <= long entry price minus Turn distance.
Exit: long, current price >= take-profit level OR current price <= stop-loss level.
Exit: short, current price <= take-profit level OR current price >= stop-loss level.
Calculation: Initial stop-loss level = entry price minus stop distance for a long, or entry price plus stop distance for a short; use Turn distance when Turn is enabled and stop-loss distance otherwise.
Calculation: Take-profit level = entry price plus profit distance for a long, or entry price minus profit distance for a short; use the Turn order's profit distance for a Turn entry. After a Step Down entry, use the unweighted mean of open entry prices on that side in place of entry price.
Calculation: Stop-loss level = initial stop-loss level, or the trailing stop when trailing is enabled and Turn is disabled.