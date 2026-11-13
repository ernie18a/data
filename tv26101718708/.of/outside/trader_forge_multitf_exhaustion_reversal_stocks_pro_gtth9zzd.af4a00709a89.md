Multi-timeframe exhaustion reversal that buys options (puts at tops, calls at bottoms). It is evaluated once per bar on the entry timeframe (hourly). It has no exit rule, only entry signals.

Indicators:
- Stoch RSI K: RSI of close, then a stochastic of that RSI over a lookback, then a short simple moving average of the result. Scale 0-100. Overbought means at or above a high threshold; oversold means at or below a low threshold.
- Compute K on the traded stock at three timeframes: entry (hourly), mid (4-hour) and macro (daily). Compute K on a benchmark market ETF (QQQ by default) at the entry and mid timeframes.
- Donchian channel on the entry timeframe: upper = highest high and lower = lowest low over a lookback.
- ATR on the entry timeframe.
- Candle body = absolute difference between open and close.
- Relative volume = current entry-timeframe volume divided by its simple moving average over a lookback.

Session filter (US Eastern time):
- Only allow bars inside the regular-session window.
- Exclude the first 15 minutes after the open.

Watch conditions (all must hold on the same bar):
- Session filter passes.
- Relative volume is at or above a minimum.
- Candle is small: body is at most a fraction of ATR.
- PUT WATCH:
  - The bar's high is within a fraction of ATR of the upper channel, or above it.
  - Stock K is overbought on entry, mid and macro timeframes.
  - Benchmark entry-timeframe K is at or above the neutral midpoint (50).
  - If the strict-alignment option is on, benchmark K is also overbought on both entry and mid timeframes.
- CALL WATCH is the mirror image:
  - The bar's low is within a fraction of ATR of the lower channel, or below it.
  - Stock K is oversold on all three timeframes.
  - Benchmark entry-timeframe K is at or below the midpoint.
  - If the strict-alignment option is on, benchmark K is also oversold on entry and mid timeframes.
- The benchmark checks are skipped if market confirmation is disabled.

Entry triggers (the structure shift after a watch):
- BUY PUT: the previous bar was a PUT WATCH and the current close is below the previous bar's low.
- BUY CALL: the previous bar was a CALL WATCH and the current close is above the previous bar's high.
- A watch alone is not a trade. Only the trigger is an entry.