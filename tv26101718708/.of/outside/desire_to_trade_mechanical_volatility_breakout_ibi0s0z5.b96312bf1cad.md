Trade one stock using a broad market index (e.g. SPY) as an external regime filter, on the same timeframe. Evaluate everything on bar close. Long is the default. Short is an optional mirror, off by default.

LONG ENTRY (when not already long): buy only if ALL of these hold:
1. Market regime: the index close is above its own long-term EMA. This is the external-data condition.
2. Stock trend: the stock close is above its long-term EMA.
3. Consolidation: take the highest high and lowest low of the prior N bars, excluding the current bar. The range height must be at least a minimum multiple and at most a maximum multiple of the stock's ATR.
4. Volatility expansion: current ATR is above its own longer-term simple average.
5. Volume: current volume divided by its recent average volume is at least a minimum threshold.
6. Trigger: the stock close is above the prior-N-bar range high.

SHORT ENTRY (optional mirror): the index close is below its long-term EMA, the stock close is below its long-term EMA, conditions 3-5 hold, and the stock close is below the range low.

EXITS (long; mirror for short):
- Initial stop: the range low captured at entry, frozen for the life of the trade. Risk R = entry price minus that stop, with a minimum of one tick.
- Take partial profit on a fixed fraction of the position when price reaches entry plus 1R.
- The remaining runner is stopped by a trailing level. This level is the higher of the initial stop and a trailing reference (a short EMA of the stock close, or alternatively a longer EMA or an ATR offset below close). It can only ratchet upward, never down.
- Close the whole position if the stock closes below its long-term EMA.
- Optionally close on an opposite-direction valid breakout signal (off by default).
- The index regime filter gates entries only. It does not trigger exits.