Trade the chart instrument on its strength relative to an external benchmark. The benchmark is user-chosen. If none is given, default by asset class: a total crypto market-cap index for crypto, the US dollar index for forex, and the S&P 500 index for everything else. Fetch the benchmark close on the chart timeframe with no lookahead, and forward-fill it on bars where it has no value.

Signals:
1. Ratio = instrument close / benchmark close. Relative strength (RS) = natural log of the ratio.
2. Rotation score (0-100): compute the RS change over three lookback horizons (short, medium, long). Convert each into a percentile rank against its own values over a rolling window. The score is the average of the three ranks.
3. Mansfield RS (percent) = (ratio / simple moving average of the ratio over a long length - 1) * 100. Positive means above its norm, negative means below.
4. RS slope z-score: slope = linear-regression endpoint value of RS over a window minus the same regression value shifted one bar back. Divide the slope by its rolling standard deviation over the rank window. If that deviation is not positive, use 0.
5. Optional price filter: instrument close vs its own long EMA.

Filters, each switchable:
- Long-OK requires Mansfield > 0, slope z-score > threshold, and close > EMA.
- Short-OK requires Mansfield < 0, slope z-score < -threshold, and close < EMA.

Entries, evaluated on bar close, with the order filled at the next bar open. Require all of: a position that is currently flat; the cooldown since the last exit has elapsed; enough warm-up bars loaded and the score and Mansfield valid; and the direction enabled.
- Go long when the score crosses upward through the entry level and Long-OK holds.
- Go short when the score crosses downward through (100 - entry level) and Short-OK holds.
- No pyramiding, and the position is sized as a fixed fraction of equity.

Exits:
- Close a long when the score falls below the exit level (lower than the entry level), or, if the Mansfield filter is on, when Mansfield turns negative.
- Close a short when the score rises above (100 - exit level), or, if the Mansfield filter is on, when Mansfield turns positive.
- Also keep a wide protective stop at a multiple of ATR from the average entry price: below entry for longs, above entry for shorts.
- After any exit, wait the cooldown number of bars before a new entry.