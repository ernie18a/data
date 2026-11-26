Calculation: Gann High Low Activator state(source, lookback, average type) = if source > MA(high, lookback, average type) then up else if source < MA(low, lookback, average type) then down else previous state
Calculation: Filtered close = if price filtering is enabled and filter multiplier > 0 and lookback 2 > 0 and abs(close - Filtered close[1]) < filter multiplier * sqrt(SMA((abs(close - close[1]) - SMA(abs(close - close[1]), lookback 2))^2, lookback 2)) then Filtered close[1] else close
Long: Gann High Low Activator state(close, lookback 1, average type 1) = up
Short: Gann High Low Activator state(close, lookback 1, average type 1) = down
Long: Gann High Low Activator state(Filtered close, lookback 2, average type 2) = up
Short: Gann High Low Activator state(Filtered close, lookback 2, average type 2) = down