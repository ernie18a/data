Use daily price, five progressively slower exponential moving averages, average true range, swing pivots, and RSI. Classify the trend as bullish when the averages are ordered fastest-to-slowest from highest to lowest (strongest if price is above the fastest average); also classify as bullish when price is above the slowest average and the faster averages are mostly ordered upward. Classify as bearish for the corresponding downward arrangements, including price below the slowest average; classify remaining cases as sideways. Treat upward and downward sideways regimes as bullish and bearish, respectively.

Apply these decisions in order:
1. If price is below the trade-filter average and has made a recent lower low, avoid trading.
2. If price has closed below the trade-filter average for the configured consecutive period, exit or cut the position.
3. If price is below the filter but has not made a recent lower low, watch without entering.
4. If price has reclaimed the filter after recently trading below the slowest average, but remains below that slowest average, wait for confirmation.
5. If price is below the slowest average, avoid trading.
6. In a bullish regime, if price is below the trade-filter average, treat the setup as risky and do not enter. Otherwise, if the move is extended from the slow average by the configured volatility or percentage threshold, the trend has lasted unusually long, or the swing count is late-stage, wait for a pullback. Otherwise, take a long position.
7. In a bearish regime, only consider a short when price is below the trade-filter average. If the move is extended, unusually old, or late-stage, wait for a pullback; otherwise, take a short.
8. In all other cases, wait.

A separate possible pullback-entry signal occurs in a bullish regime when price is not below the trade-filter average and the bar’s range touches the fastest average. Weekly trend alignment, relative strength versus the market index, and the suggested stop and target are informational and do not alter these trade decisions.