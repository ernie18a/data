Calculation: Effort z-score = (volume − rolling mean(volume, lookback)) / rolling standard deviation(volume, lookback); use 0 when standard deviation is 0
Calculation: Result = selected bar range (high − low), absolute body (|close − open|), or true range
Calculation: Result z-score = (Result − rolling mean(Result, lookback)) / rolling standard deviation(Result, lookback); use 0 when standard deviation is 0
Calculation: Divergence z-score = z-score of (Effort z-score − Result z-score), using the same lookback; use 0 when standard deviation is 0
Calculation: Absorption = either (Divergence z-score ≥ threshold AND Effort z-score > 0 AND Result z-score < 0) or (Effort z-score ≥ threshold AND Result z-score ≤ −threshold)
Calculation: Active zone = an absorption bar's high–low, expanded to include each subsequent nonbreaking bar's high and low; close is checked against the zone before that bar is added. A subsequent absorption refreshes the zone's deadline. Discard the zone if no breakout occurs within the maximum bars since the most recent absorption.
Long: active zone AND close > zone high
Short: active zone AND close < zone low