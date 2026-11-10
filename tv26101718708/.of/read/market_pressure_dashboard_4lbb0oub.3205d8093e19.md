Calculation: Normalized pressure = map the percentile rank of an EMA of raw delta to a scale from -100 to 100. Raw delta = candle body divided by high minus low, or zero when high equals low, multiplied by capped relative volume raised to a volume-weight exponent. Relative volume = volume divided by its SMA, or one when the SMA is not positive.
Calculation: Normalized momentum = map the percentile rank of an EMA of the change in normalized pressure over a momentum lookback to a scale from -100 to 100.
Calculation: Composite score = EMA of the weighted average of normalized pressure and normalized momentum.
Calculation: Trend bias = a slower EMA of the composite score.
Calculation: Significant divergence = percentile rank of the negative product of normalized pressure and normalized momentum is above its upper threshold AND the negative product is positive AND the smaller absolute value of normalized pressure and normalized momentum is above its minimum threshold AND ATR percentile rank is between its lower and upper thresholds inclusive. The divergence percentile uses the pressure normalization lookback.
Long: Normalized pressure > 0 OR normalized momentum > 0 OR composite score > 0 OR trend bias > 0.
Short: Normalized pressure <= 0 OR normalized momentum <= 0 OR composite score <= 0 OR trend bias <= 0.
Long: Composite score crosses above zero AND significant divergence is false.
Short: Composite score crosses below zero AND significant divergence is false.