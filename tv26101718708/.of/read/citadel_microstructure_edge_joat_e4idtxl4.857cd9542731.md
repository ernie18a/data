Calculation: Rolling z-score = (value − rolling simple mean) / rolling population standard deviation; return zero when the standard deviation is zero or unavailable.
Calculation: Tick imbalance = for each chart bar, classify each completed lower-timeframe bar by comparing its close with the preceding lower-timeframe close, carrying the prior classification when equal and carrying both close and classification across chart bars; the initial classification is neutral. Divide the number of positive classifications minus negative classifications by the number of lower-timeframe bars, and separately divide positive-classified volume minus negative-classified volume by total volume, returning zero for a zero denominator. Blend these two ratios with configurable weights. Optionally apply the hyperbolic tangent of the rolling z-score of the blend.
Calculation: Spread z-score = rolling z-score of the EMA of (high − low) / close, using zero when close is zero.
Calculation: Micro momentum = hyperbolic tangent of the rolling z-score of the shorter-period close EMA minus the longer-period close EMA.
Calculation: Edge = clamp the sum of the previous edge multiplied by a decay factor and the current contribution to a symmetric range; initialize the previous edge to zero. Contribution is the weighted sum of clamped tick imbalance, clamped micro momentum, and sign of clamped micro momentum multiplied by the absolute value of clamped negative spread z-score divided by a spread scale. Clamp each component to a symmetric unit range. Optionally normalize the three nonnegative weights by their sum, using a positive minimum denominator.
Long: Edge crosses above a positive threshold AND bars since the last long signal are at least the cooldown when opposite-side signals are allowed during cooldown, OR edge crosses above the positive threshold AND bars since the last signal of either side are at least the cooldown when they are not.
Short: Edge crosses below the negative threshold AND bars since the last short signal are at least the cooldown when opposite-side signals are allowed during cooldown, OR edge crosses below the negative threshold AND bars since the last signal of either side are at least the cooldown when they are not.
Long: Edge >= 0.
Short: Edge < 0.
Long: Tick imbalance >= 0.
Short: Tick imbalance < 0.
Long: Spread z-score <= 0.
Short: Spread z-score > 0.
Long: Micro momentum >= 0.
Short: Micro momentum < 0.