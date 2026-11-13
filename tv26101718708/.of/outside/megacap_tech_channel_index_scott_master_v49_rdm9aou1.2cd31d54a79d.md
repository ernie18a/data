Long-only framework for a single equity. Entries are gated by two external regime filters, evaluated on the previous completed daily bar to avoid lookahead.

External gates (all must hold for a new long entry):
1. Sector trend gate: the previous daily close of a tech sector index (NASDAQ-100 Technology) must be above that index's daily exponential moving average, computed on prior-day data.
2. Volatility gate: the previous daily close of the VIX must be at or below a hard-block ceiling. Above the ceiling, no new buys are allowed.
3. Earnings blackout gate (optional, on by default): estimate the next earnings date as the last reported earnings date plus about 90 days. Block entries within a few days before that estimate. Also block entries within a few days after it, unless the last earnings surprise was modestly positive (a small positive band, not too large). Disable the gate if the user turns it off.

Entry (go long) requires the external gates above plus these conditions on the traded instrument:
- The bar's low touches or pierces a lower channel: an exponential moving average of close minus a multiple of ATR.
- The bar is bullish (close above open).
- A short-smoothed RSI is at or below an adaptive oversold threshold. The threshold is a low percentile of the smoothed RSI over a rolling window of about one quarter. Use a shorter window with different percentiles during a warm-up period, and a fixed fallback value before that.
- A re-arm flag is set. It clears after an entry and sets again once price closes back at or below a small premium above the EMA.
- Price is not chasing: close is below the EMA by a small margin.
- The regular New York session is open, the bar is confirmed, and there is no open position.
- Sizing passes: share count is a fixed dollar budget divided by a slightly buffered price, scaled by a regime multiplier. The multiplier is larger when VIX is low and the index is up, smaller when VIX is at panic level, and 1 otherwise. Quantity must be at least 1 and affordable, and ATR times quantity must exceed a minimum multiple of commissions.
Place a buy limit order slightly above the close. A global manual pause input exists as an override.

Exits (long only, no shorting). These depend only on the instrument's own data:
- Initial hard stop at entry price minus a multiple of ATR (or a fixed percent if ATR stop is disabled).
- A ratcheting trailing stop at close minus a multiple of ATR. It never moves down. Once open profit exceeds a small percent, the stop is floored slightly above entry.
- The active stop is the higher of the initial stop and the trailing stop, executed as a stop exit.
- Climax exit: after a minimum number of bars held, on a confirmed bar in session, close the whole position at market if the smoothed RSI reaches an adaptive overbought threshold (a high percentile, with the same warm-up and fallback scheme) or close is far above the EMA by a multiple of ATR.
- Cancel pending orders near the end of the session.