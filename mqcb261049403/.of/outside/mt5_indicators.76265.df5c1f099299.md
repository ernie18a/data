Mean-reversion entry signal for the traded instrument, built from its relationship to a second, user-chosen reference instrument on the same timeframe. Evaluate once per completed bar.

Inputs: close series of the traded instrument, close series of the reference instrument, a correlation lookback, a spread lookback, a correlation decoupling threshold, and a spread z-score threshold.

Data alignment: for each bar of the traded instrument, take the reference close from the reference bar at the same timestamp (the latest reference bar at or before that time). If a reference close is missing or non-positive, treat both returns for that bar as zero and carry the previous spread forward.

Step 1, returns: for each bar, compute the simple percentage return (close minus previous close, divided by previous close) for both the traded and reference instruments.

Step 2, correlation: compute the Pearson correlation between the two return series over the most recent correlation-lookback bars, including the current bar. If the denominator is zero, use 0. Clamp the result to [-1, 1]. The pair is 'decoupled' when the absolute correlation is below the decoupling threshold.

Step 3, spread z-score: define the spread on each bar as the natural log of (traded close divided by reference close). Over the most recent spread-lookback bars, including the current bar, compute the mean and the population standard deviation (divide by N) of the spread. The z-score is (current spread minus mean) divided by standard deviation, or 0 if the standard deviation is zero.

Step 4, signals: take no signal until at least the larger of the two lookbacks of bars exist. A signal fires only when the pair is decoupled AND the spread is extreme:
- LONG the traded instrument if the z-score is less than or equal to the negative z-score threshold. The traded instrument has lagged the reference and is expected to catch up.
- SHORT the traded instrument if the z-score is greater than or equal to the positive z-score threshold. The traded instrument has run ahead of the reference and is expected to give back gains.
- Otherwise no signal.
The signals are mutually exclusive and are recomputed fresh on every bar, so they do not persist from one bar to the next.

Exit: no exit rule is defined. The logic only produces long and short entry signals. Position management, stops, and any exit when correlation recovers or the z-score reverts toward zero must be supplied separately. The source suggests optionally confirming entries with price action or momentum on the traded instrument, but that is not part of the computed logic.