Calculation: Footprint rows = Divide the chart bar's low-to-high range into equal rows. Choose the row count as the rounded range divided by a configurable row size, bounded below by 1 and above by a configurable maximum. Row size is either fixed or a configurable multiple of the simple average of chart-bar true range including the current bar, rounded to price precision; use the minimum price increment if the result is nonpositive.
Calculation: Row buy and sell volume = For each lower-timeframe bar within the chart bar, including the bar still forming, allocate its volume to each intersecting row in proportion to the overlap of their high-low ranges divided by the lower-timeframe range; if that range is zero, allocate its full volume to each intersecting row. Allocate the resulting volume to buy if lower-timeframe close > open, to sell if close < open, and equally to both if close = open. Sum each allocation per row.
Calculation: Row delta ratio = (row buy volume - row sell volume) / (row buy volume + row sell volume), or 0 if the denominator is 0.
Calculation: Bar delta = sum of row buy volume minus row sell volume across all footprint rows.
Long: At least a configurable number of consecutive rows have row delta ratio >= the stacked-imbalance threshold.
Short: At least a configurable number of consecutive rows have row delta ratio <= the negative stacked-imbalance threshold.
Long: Row count >= the absorption row count AND close < open AND sum of buy volume in the lowest absorption rows / sum of total volume in those rows >= the absorption threshold, with the ratio set to 0 when total volume is 0.
Short: Row count >= the absorption row count AND close > open AND sum of sell volume in the highest absorption rows / sum of total volume in those rows >= the absorption threshold, with the ratio set to 0 when total volume is 0.
Long: Row count >= 2 AND total volume in the lowest row > 0 AND sell volume / total volume in the lowest row >= the unfinished-business threshold.
Short: Row count >= 2 AND total volume in the highest row > 0 AND buy volume / total volume in the highest row >= the unfinished-business threshold.
Long: Low < the lowest low of the preceding divergence-lookback bars AND bar delta > 0.
Short: High > the highest high of the preceding divergence-lookback bars AND bar delta < 0.
Long: Bar delta > 0 AND previous bar delta <= 0.
Short: Bar delta < 0 AND previous bar delta >= 0.
Long: Bar delta >= 0.
Short: Bar delta < 0.