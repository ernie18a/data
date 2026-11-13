Long-only candidate ranking on the traded instrument, built from a weighted additive score. It uses data from a second benchmark index instrument (default: broad US equity index ETF) and from daily-timeframe data of the traded instrument. The output is a long-candidate flag, with no short or exit logic.

Score components, each worth a fixed number of points if true and zero otherwise:
1. Volume gate (largest weight): current volume divided by its simple moving average over a lookback is at or above a minimum multiple.
2. Daily trend up (medium weight): on daily bars, the 20-day SMA is above the 50-day SMA, the 50-day SMA is above the 200-day SMA, and the daily close is above the 50-day SMA.
3. Relative strength vs benchmark (medium weight, the outside-data condition): the traded instrument's percent change in daily close over a lookback of N daily bars minus the benchmark's percent change over the same lookback is greater than zero.
4. Setup signal present (largest weight, tied with the volume gate): either of two setups.
   - Breakout: the close is above the highest high of the prior Donchian-lookback bars (excluding the current bar), AND the volume gate is true, AND the instrument is coiled, AND the daily trend is up.
   - Power Play day 2: the previous bar was a large up bar (its high-low range as a percent of its low is at least a threshold, it closed above its open, it closed in the upper portion of its range by at least a given fraction, and its relative volume met the volume gate). The current bar must trade below the previous close at some point (low below previous close), close above its open, and close in the upper half of its own range.
5. Coil (small weight): a squeeze is on now or was on within the last few bars. Squeeze means the Bollinger Bands (SMA +/- a multiple of stdev of close) lie entirely inside the Keltner-style channel (SMA +/- a multiple of the SMA of true range).
6. Near breakout level (small weight): the close is within a small percent of the prior range high (highest high of the prior Donchian-lookback bars, excluding the current bar).
7. Reward-to-risk feasible (small weight): (prior range high - close) divided by max(close - prior range low, tiny positive number) is at or above a minimum ratio. The prior range low is the lowest low of the prior Donchian-lookback bars, excluding the current bar.

The composite score is the sum of the points, scaled 0-100.

Decision tiers: a high score means a high-conviction long candidate, a medium score means a watchlist or stalk candidate, and a lower score means a partial setup or skip. A concrete long entry trigger is the breakout or Power Play signal. A high-conviction long alert fires when the composite score reaches the upper threshold, and a watchlist alert fires at the middle threshold.