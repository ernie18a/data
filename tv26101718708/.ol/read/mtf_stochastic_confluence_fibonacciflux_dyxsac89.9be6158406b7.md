Calculation: %K = smoothed Stochastic %K, using the same lookback and smoothing parameters for all three legs: the chart timeframe and two higher timeframes; use the last completed bar for each leg.
Calculation: %D = moving average of %K, using the same smoothing parameter for all three legs and the corresponding completed bars.
Calculation: Turn = current %K minus its previous value.
Calculation: Normalized weights = each leg's weight divided by the sum of the three weights.
Calculation: Composite = weighted mean of the three %K values.
Calculation: Coherence = 100 × (1 − clamp to [0,1] of the weighted standard deviation of the three normalized %K values, where each normalized %K is (%K − 50) / 50).
Calculation: Bull position = weighted mean of each leg's clamp to [0,1] of (oversold + soft-band width − %K) / soft-band width.
Calculation: Bear position = weighted mean of each leg's clamp to [0,1] of (%K − (overbought − soft-band width)) / soft-band width.
Calculation: Bull turn = weighted mean of each leg's clamp to [0,1] of Turn / full-turn slope; bear turn = weighted mean of each leg's clamp to [0,1] of −Turn / full-turn slope.
Calculation: Bull cross = sum of normalized weights for legs where %K > %D; bear cross = sum of normalized weights for legs where %K < %D.
Calculation: Bull score = 100 × bull position × (0.30 + 0.25 × Coherence / 100 + 0.30 × bull turn + 0.15 × bull cross); bear score = 100 × bear position × (0.30 + 0.25 × Coherence / 100 + 0.30 × bear turn + 0.15 × bear cross).
Long: all three %K values ≤ oversold OR (each leg has been ≤ oversold within the cluster lookback AND at least two legs have Turn > 0 when the turning filter is enabled AND bull score ≥ trigger threshold AND no prior long trigger since reset; reset the long latch when Composite > 55 or the long cluster condition becomes false).
Short: all three %K values ≥ overbought OR (each leg has been ≥ overbought within the cluster lookback AND at least two legs have Turn < 0 when the turning filter is enabled AND bear score ≥ trigger threshold AND no prior short trigger since reset; reset the short latch when Composite < 45 or the short cluster condition becomes false).