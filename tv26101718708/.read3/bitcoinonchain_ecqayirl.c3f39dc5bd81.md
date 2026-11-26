Calculation: PercentileScore(x) = PercentileRank(x, shared lookback converted from T1 periods to chart bars), mapped linearly from the median rank to the score scale; calculated on chart bars using x from the last completed T1 bar.
Calculation: SOPR score = PercentileScore(SOPR − SOPR breakeven).
Calculation: Active-address score = PercentileScore(Active Addresses).
Calculation: New-address score = PercentileScore(New Addresses).
Calculation: Transaction-fee score = PercentileScore(Transaction Fees USD).
Calculation: Hash-rate score = PercentileScore(Hash Rate).
Calculation: Sending-address score = the inverse of PercentileScore(Sending Addresses).
Calculation: Weighted composite = weighted mean of the six scores using separate weights; with the dead-feed guard enabled, carry each metric’s last valid positive value for scoring and omit non-live metrics and their weights, then renormalize; with the guard disabled, replace missing values with zero (SOPR with its breakeven) and retain all weights.
Calculation: Smoothed composite = EMA(weighted composite, composite smoothing lookback).
Calculation: Signal line = EMA(smoothed composite, separate signal lookback).
Calculation: Histogram = smoothed composite − signal line.
Long: Smoothed composite crosses above the signal line AND was below its zero line on the preceding chart bar.
Short: Smoothed composite crosses below the signal line AND was above its zero line on the preceding chart bar.
Long: Smoothed composite crosses above its zero line.
Short: Smoothed composite crosses below its zero line.
Long: On the chart bar confirming a price pivot low using separate left and right lookbacks, the pivot low is below the preceding confirmed pivot low, the smoothed composite at the pivot is above its value at the preceding pivot, and the pivots are no farther apart than the maximum pivot gap.
Short: On the chart bar confirming a price pivot high using separate left and right lookbacks, the pivot high is above the preceding confirmed pivot high, the smoothed composite at the pivot is below its value at the preceding pivot, and the pivots are no farther apart than the maximum pivot gap.
Long: The most recent confirmed divergence is bullish and its confirmation is within the maximum pivot gap.
Short: The most recent confirmed divergence is bearish and its confirmation is within the maximum pivot gap.
Long: The most recent filtered crossover was upward.
Short: The most recent filtered crossover was downward.
Long: Smoothed composite is at or above the healthy-regime boundary.
Short: Smoothed composite is at or below the negative healthy-regime boundary.
Long: Smoothed composite is at or above the strong-regime threshold.
Short: Smoothed composite is at or below the negative strong-regime threshold.
Long: SOPR from the last completed T1 bar, with missing values treated as breakeven, is at or above its breakeven level.
Short: SOPR from the last completed T1 bar, with missing values treated as breakeven, is below its breakeven level.
Long: Any on-chain metric score, signal line, or histogram is at or above the score color threshold.
Short: Any on-chain metric score, signal line, or histogram is at or below the negative score color threshold.
Long: Smoothed composite is at or above its zero line.
Short: Smoothed composite is below its zero line.
Long: Histogram is at or above its zero line.
Short: Histogram is below its zero line.