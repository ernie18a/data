Intraday trend-following momentum system. All inputs come from the traded underlying's own bars, which are used to decide when to buy long-side or short-side exposure (calls or puts). Evaluate on each confirmed bar close and fill at that close. Hold at most one position, with no pyramiding. Long and short sides have independent parameter sets, and a setting can restrict trading to long only, short only, or both.

Indicators per side: fast EMA and slow EMA of close, RSI of close, ATR, and a simple moving average of volume.

Entry gate (all must hold): the bar is inside regular US market hours (New York time); it is not inside a configured late-afternoon no-trade window; it is not inside an optionally excluded opening window; the position is flat; and the system is not in cooldown. The cooldown is waived only for a qualifying reversal (see Cooldown).

Long entry (all required):
1. Trend is up: fast EMA is above slow EMA, and their absolute gap is at least a minimum distance in price units.
2. RSI momentum: RSI crosses upward through a long threshold on this bar, or RSI is at or above that threshold while not in cooldown.
3. RSI is at or below an upper cap, so overbought extremes are rejected.
4. Volume spike: current volume is at least a multiple of its moving average.
5. Candle body filter, if enabled: |close - open| / (high - low + a tiny epsilon) is at least a minimum ratio.
6. VWAP filter, if enabled: close is above VWAP.

Short entry is the mirror image:
1. Fast EMA is below slow EMA, with the same minimum gap.
2. RSI crosses downward through a short threshold on this bar, or RSI is at or below that threshold while not in cooldown.
3. RSI is at or above a lower floor, so oversold extremes are rejected.
4. The same volume spike condition holds.
5. The same candle body filter holds.
6. VWAP filter, if enabled: close is below VWAP.

Cooldown: after a trade closes, block new entries until a set number of bars after the exit bar. The block is lifted if reversal-exemption is enabled and a reversal is possible. A reversal is possible when the last closed trade was long and the short trend holds with RSI crossing down through, or already at or below, the short threshold. It is also possible when the last closed trade was short and the long trend holds with RSI crossing up through, or already at or above, the long threshold.

Exits:
- At entry, fix a stop at an ATR multiple from the entry close. It sits below the entry for longs and above it for shorts.
- At entry, fix a take-profit at the same ATR distance times a reward-to-risk ratio, on the opposite side of the entry from the stop.
- Both levels stay fixed for the life of the trade. The position exits when price hits either one.
- Optionally, force-close any open position at the 15:55 New York bar, which is shortly before the close, so nothing is held overnight.
- There is no signal-based exit. A reversal is handled only by a new opposite entry after the stop or target has closed the position, with the cooldown waived.