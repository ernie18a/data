Long-only, daily-timeframe trend filter that uses a benchmark index (a different instrument from the one traded) for relative strength. It never goes short. Evaluate on each bar's close. The instrument is 'ready' only if every condition below holds. Any missing or insufficient data counts as a fail.

Trend conditions on the traded instrument (fast, medium and slow simple moving averages of close, e.g. 50/150/200 bars):
1. Close is above both the medium and slow averages.
2. The medium average is above the slow average.
3. The slow average is rising: its current value is strictly above its value about one month of bars ago.
4. The fast average is above both the medium and slow averages.
5. Close is above the fast average.
6. Close is at least a minimum percentage above the lowest low of the past 252 bars.
7. Close is within a maximum percentage below the highest high of the past 252 bars.

Relative strength versus the benchmark (the benchmark's close on the same timeframe, with no lookahead). All four sub-conditions must hold:
- The RS line (instrument close / benchmark close) is above its own medium-length simple moving average.
- The Mansfield reading is at or above its minimum (zero). It is the RS line divided by its 252-bar simple average, minus 1, in percent.
- The weighted relative performance is at or above parity (1.0). For each of 63, 126, 189 and 252 bars, take the instrument's price ratio over that window divided by the benchmark's price ratio over the same window. Combine the four with a heavier weight on the shortest horizon and equal smaller weights on the other three. Treat a missing ratio as zero in the combination.
- The 252-bar relative ratio alone is at or above parity.
Ignore the optional externally supplied 1-99 rating; it is off by default.

Extension guard: compute the percent distance of close above the fast average. If it is at or above a 'too extended' limit, the instrument is not ready, even when all the conditions above pass. Between a smaller warning level and that limit the instrument is still ready. The warning level only affects the label.

Up-volume versus down-volume and the 'optimal' grading tiers are informational only and do not affect decisions.

Decisions:
- Enter long on the bar where 'ready' becomes true after the previous bar was not ready.
- Stay long while ready remains true.
- Exit, or stay flat, whenever any condition fails or the instrument becomes too extended.
- There is no short signal.