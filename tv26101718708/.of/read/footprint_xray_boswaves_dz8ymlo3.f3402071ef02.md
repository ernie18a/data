Calculation: Footprint rows = Divide the chart bar's low-to-high range into max(1, round(range / row size)) equal rows. Row size is a parameter or ATR multiplied by a parameter and rounded to a price increment. Allocate each lower-timeframe bar's volume to every overlapping row in proportion to the overlap divided by its range; for a zero-range bar allocate its full volume to each overlapping row. Allocate bullish lower-timeframe bars to buy volume, bearish bars to sell volume, and doji bars equally to both. Use the lower-timeframe bars within the chart bar, including the bar still forming. Row total is buy plus sell volume; row delta ratio is (buy volume minus sell volume) / row total, or zero when row total is zero.
Calculation: Bar delta = Current chart bar's cumulative lower-timeframe signed volume minus the preceding chart bar's cumulative lower-timeframe signed volume. Reset the cumulative sum at each chart bar. Sign each lower-timeframe bar's volume positive when close > open and negative when close < open; when close = open, use the sign of close versus the preceding lower-timeframe close, or carry forward the preceding sign when those closes are equal. Use lower-timeframe bars within each chart bar, including the bar still forming.
Long: Any footprint row delta ratio > 0
Short: Any footprint row delta ratio < 0
Long: At least a parameterized number of consecutive footprint rows have delta ratios >= the stacked-imbalance threshold
Short: At least a parameterized number of consecutive footprint rows have delta ratios <= the negative stacked-imbalance threshold
Long: Close < open AND the number of footprint rows >= the extreme-row count AND the sum of buy volume in the bottom extreme-row count / the sum of total volume in those rows >= the absorption threshold
Short: Close > open AND the number of footprint rows >= the extreme-row count AND the sum of sell volume in the top extreme-row count / the sum of total volume in those rows >= the absorption threshold
Long: The number of footprint rows >= 2 AND bottom-row total volume > 0 AND bottom-row sell volume / total volume >= the unfinished-business threshold
Short: The number of footprint rows >= 2 AND top-row total volume > 0 AND top-row buy volume / total volume >= the unfinished-business threshold
Long: Low < the lowest low of the preceding lookback bars AND bar delta > 0
Short: High > the highest high of the preceding lookback bars AND bar delta < 0
Long: Bar delta >= 0
Short: Bar delta < 0
Long: Bar delta > 0 AND previous bar delta <= 0
Short: Bar delta < 0 AND previous bar delta >= 0