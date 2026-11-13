Calculation: ATR = Average True Range of the chart timeframe
Calculation: Pivot high/low = bar whose high (low) is the highest (lowest) within N bars on each side; it is confirmed N bars later and registered on the confirmation bar (pivot high first, then pivot low if both occur on the same bar)
Calculation: Shelf ledger = list of shelves (price, touches). For each registered pivot: if |pivot price - shelf price| <= clusterK*ATR for an existing shelf (use the most recently added matching one), then that shelf's touches += 1 and its price = (shelf price + pivot price)/2; otherwise append a new shelf with price = pivot price and touches = 1; if the list exceeds the max count, drop the oldest shelf
Calculation: S = among shelves with touches >= minTouches, the shelf price with the smallest |close - shelf price| (evaluated every bar after the ledger update); none if no shelf qualifies
Calculation: buf = rejectK*ATR (rejectK < clusterK)
Calculation: RejUp = S exists AND low <= S+buf AND high >= S-buf AND close > S+buf AND close > open
Calculation: RejDown = S exists AND low <= S+buf AND high >= S-buf AND close < S-buf AND close < open
Calculation: Bias = +1 from the latest RejUp, -1 from the latest RejDown; it persists until the opposite rejection occurs; 0 before the first rejection
Calculation: EMA = exponential moving average of close (short length)
Long: Bias = +1 AND close crosses above EMA (close > EMA AND previous close <= previous EMA) AND position is not already long (flat or short) AND bars since the last entry signal (long or short) >= cooldown
Long: (alternative rejection-only mode, used instead of the line above) RejUp AND position is not already long AND bars since the last entry signal >= cooldown
Short: Bias = -1 AND close crosses below EMA (close < EMA AND previous close >= previous EMA) AND position is not already short (flat or long) AND bars since the last entry signal (long or short) >= cooldown
Short: (alternative rejection-only mode, used instead of the line above) RejDown AND position is not already short AND bars since the last entry signal >= cooldown