Calculation: Raw bullish SuperTrend flip = SuperTrend direction changes from bearish to bullish.
Calculation: Raw bearish SuperTrend flip = SuperTrend direction changes from bullish to bearish.
Calculation: Effective bullish probability = bullish EW probability when inversion is disabled, otherwise bearish EW probability.
Calculation: Effective bearish probability = bearish EW probability when inversion is disabled, otherwise bullish EW probability.
Calculation: EW bullish and bearish probabilities = assign a clipped logistic probability from the EW score to the detected wave direction, with bullish and bearish probabilities complementary; use 0.5 for each when no direction is detected. The EW score combines impulse quality, wave-position score, current-leg Fibonacci fit, invalidation risk, time decay, momentum profile, volume profile, and directional bias using their separate configured weights.
Calculation: EW impulse quality and wave position = score the best valid pivot-based Elliott impulse count, prioritizing a completed five-wave count, then developing counts; use alternating confirmed swing pivots qualified by the configured pivot lookbacks, ATR-based minimum swing, and maximum pivot age.
Calculation: Current-leg Fibonacci fit = Fibonacci confluence of the developing leg’s retracement or extension ratio against its wave-specific targets, adjusted by tolerance and wave degree.
Calculation: Invalidation risk = clamp(1 - (directional distance from the wave invalidation anchor / ATR-based degree-scaled buffer)^2, 0, 1), with risk 1 when price has crossed the anchor; use W1 as the anchor for W4 when diagonal overlap is disallowed, otherwise W0.
Calculation: Time decay = clamp(bars since the last accepted pivot / the configured degree-scaled time horizon, 0, 1).
Calculation: Momentum profile and volume profile = wave-position-specific scores from directional price velocity relative to ATR and volume relative to its moving average.
Long: Raw bullish SuperTrend flip.
Short: Raw bearish SuperTrend flip.
Long: Raw bullish SuperTrend flip AND effective bullish probability >= long flip threshold AND effective bearish probability <= fade threshold.
Short: Raw bearish SuperTrend flip AND effective bearish probability >= short flip threshold AND effective bullish probability <= fade threshold.
Long: Raw bullish SuperTrend flip AND NOT (effective bullish probability >= long flip threshold AND effective bearish probability <= fade threshold).
Short: Raw bearish SuperTrend flip AND NOT (effective bearish probability >= short flip threshold AND effective bullish probability <= fade threshold).
Long: SuperTrend direction is bullish AND (effective bullish probability >= medium color threshold OR low-probability trail dimming is disabled).
Short: SuperTrend direction is bearish AND (effective bearish probability >= medium color threshold OR low-probability trail dimming is disabled).