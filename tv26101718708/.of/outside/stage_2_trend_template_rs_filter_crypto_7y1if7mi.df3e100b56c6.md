Long-only eligibility filter on a daily chart of a crypto symbol, using a second benchmark symbol's closes (a major coin or broad crypto index) as external data. Each bar is classed 'tradeable' or not. Go long (armed) on the first bar where tradeable turns true after being false. Stay long while it remains true. Exit to flat when it turns false. There are no shorts. The 'optimal' grading, the volume check and the 'warning' extension zone do not change the decision.

Tradeable is true only when all five mandatory checks pass at their minimum level and the extension check is not failed. Any missing or insufficient data counts as a fail.

1. Stack: close > fast SMA > mid SMA > slow SMA of closes.
2. Slow SMA rising: the current slow SMA is strictly greater than its value a configurable 'slope minimum' number of bars ago (about one month).
3. Off the low: close is at least a minimum percentage above the lowest low of the trailing 365 bars. Percentage = close / lowest low - 1.
4. Near the high: close is no further than a maximum percentage below the highest high of the trailing 365 bars. Percentage = 1 - close / highest high.
5. Relative strength versus the benchmark. All four sub-conditions must hold, and all inputs must be available:
   a. RS line = symbol close / benchmark close, and it is above its own short SMA.
   b. Mansfield value = (RS line / its SMA over 365 bars - 1) * 100, and it is at least a minimum threshold (zero or so).
   c. Weighted relative performance is at least a minimum threshold (neutral parity). For each lookback of 90, 180, 270 and 365 bars: relative = (symbol close / symbol close that many bars ago) / (benchmark close / benchmark close that many bars ago). Weighted = weighted sum of the four, with the most recent quarter weighted double each of the other three, and weights summing to 1. A missing term counts as zero.
   d. The 365-bar relative performance is at least parity (symbol did at least as well as the benchmark over the year).

Extension check: extension = close / fast SMA - 1, in percent. If it is at or above a 'too extended' threshold (much larger than the warning level), tradeable is false even if the five checks pass. Between the warning level and the too-extended level it is still allowed. Below the warning level it is allowed.

Benchmark data uses the same timeframe as the chart, aligned bar by bar, with no lookahead. The 365-bar windows assume daily bars, since crypto trades every calendar day.