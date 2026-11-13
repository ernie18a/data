Long-only entry framework. There is no short logic and no exit logic. A long entry fires on a bar only when all of the following hold at once.

1. RSI quality: RSI of the close is inside a configured 'good' band (lower to upper bound), or it is above the neutral midline of the RSI scale and at or below the band's upper bound.
2. RSI momentum: RSI is strictly rising for two consecutive bars (current > previous > the one before).
3. Volume confirmation, either of:
   a. In any of the last few bars (a short lookback including the current bar), volume exceeded a multiple of that bar's own volume moving average.
   b. Current volume is above its volume moving average, and a short volume SMA is above a longer volume SMA.
4. Consolidation: over a rolling lookback window, range % = (highest high - lowest low) / lowest low * 100. A bar is 'tight' if the range % is at or below a maximum. Count consecutive tight bars, resetting to zero on a non-tight bar. Consolidation holds when the count reaches a minimum.
5. Near breakout: close is above the midpoint of the window's high/low range, and no more than a small tolerance above the window's highest high.
6. Instrument short-term trend: close is above a fast EMA, and the fast EMA is above a slow EMA.
7. Market filter, using external data. If the filter is enabled, take the close of a broad-market reference symbol (such as a market index ETF) on the same timeframe as the chart. Compute fast, slow and long-term EMAs of that close, using the same fast and slow lengths as the instrument's EMAs plus a long-term length. The market is bullish only when the reference's fast EMA is above its slow EMA and its close is above its long-term EMA. Entry requires a bullish market. If the filter is disabled, this condition always passes.

When all seven conditions are true, go long (buy signal). Nothing else triggers a trade. Weaker tiers such as 'early setup' and 'watch' are informational only.