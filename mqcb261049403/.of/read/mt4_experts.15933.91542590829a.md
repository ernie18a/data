Calculation: Buy score = Truncated integer percentage of all votes that favor buying, pooled across every configured timeframe except the largest; on each timeframe compare the current forming bar with the previous completed bar, casting one buy vote for each strictly higher open, high, low, close, (high + low) / 2, (high + low + close) / 3, and (high + low + 2 × close) / 4, and a sell vote otherwise. The configured timeframes may be higher or lower than the chart timeframe.
Calculation: Sell score = Truncated integer percentage of all votes that favor selling, pooled across the same timeframes and comparisons as the buy score.
Long: Buy score > opening threshold
Short: Sell score > opening threshold
Exit: Long, Buy score < closing threshold
Exit: Short, Sell score < closing threshold