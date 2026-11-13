Signal-only logic: it emits a long alert on a bullish trigger and a short alert on a bearish trigger. It defines no explicit exit, stop or position sizing. Treat an opposite trigger as the only reversal. The decision uses data from two external instruments, a broad-market ETF (SPY) and the front-month index futures contract (ES), regardless of the chart instrument.

Per-bar features, computed separately for each external instrument on each of four timeframes, ranging from short intraday to hourly:
1. Close position in range: ((close - low) / (high - low)) rescaled to the range -1 to +1. It is 0 if the bar has no range.
2. Relative volume: volume divided by its own simple moving average over a fixed lookback. It is 0 if the average is not positive. Each instrument is normalized against its own average, so share and contract counts are never mixed.
3. Pressure: an exponential moving average, computed on that timeframe's own bars, of (relative volume * close position in range).
4. Candle direction: up if close > open, down if close < open.
5. Optional non-repainting mode: use the values of the last completed bar on each timeframe instead of the forming bar. Higher-timeframe data is fetched with no lookahead.

Per-timeframe score (+1, -1 or 0):
- Average the two instruments' relative volume. Call the timeframe volume-active if this average exceeds a relative-volume threshold.
- Sum the two instruments' pressure values to get the combined delta.
- Score +1 if volume-active, combined delta > 0, and both instruments' candles are up.
- Score -1 if volume-active, combined delta < 0, and both instruments' candles are down.
- Otherwise score 0. This includes disagreement between the instruments.

Session filter: if enabled, force every timeframe score to 0 outside regular US equity trading hours (New York time).

Aggregate: total score = sum of the four timeframe scores, from -4 to +4. All timeframes are weighted equally.

Trigger with persistence:
- Bull hold is true when total score >= a strong threshold for a required number of consecutive chart bars. Bear hold is true when total score <= the negative of that threshold for the same number of consecutive bars.
- Bullish trigger (go long) fires only on the bar where bull hold turns from false to true. Bearish trigger (go short) fires only on the bar where bear hold turns from false to true. Holding the condition afterward does not re-fire.
- Scores between the thresholds, including mixed and zero scores, produce no action.

The short-term implied volatility index (VIX1D) is bucketed into four regimes (compressed, normal, elevated, extreme) using fixed cut levels. This is display context only and does not gate or alter any trigger.