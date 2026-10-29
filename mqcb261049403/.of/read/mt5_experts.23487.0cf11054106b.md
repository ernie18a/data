Calculation: Moving average = linear-weighted moving average of weighted price (high + low + 2 × close) / 4
Calculation: Standard deviation = linear-weighted standard deviation of weighted price (high + low + 2 × close) / 4
Long: Previous completed chart-timeframe moving average − standard deviation − buffer > current price
Short: Previous completed chart-timeframe moving average + standard deviation + buffer < current price
Exit: Long, current price <= active stop-loss (initially entry price − stop-loss distance, then trailed) OR current price >= entry price + take-profit distance
Exit: Short, current price >= active stop-loss (initially entry price + stop-loss distance, then trailed) OR current price <= entry price − take-profit distance