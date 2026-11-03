Calculation: Smoothed base = EMA of the volume-weighted average of close over a lookback; its smoothing lookback is shorter than the VWMA lookback.
Calculation: Volume-weighted standard deviation = square root of the volume-weighted average of squared differences between close and the smoothed base, over the same lookback as the VWMA.
Calculation: Upper ribbon = smoothed base + volume-weighted standard deviation × ribbon-width multiplier.
Calculation: Lower ribbon = smoothed base − volume-weighted standard deviation × ribbon-width multiplier.
Long: Close crosses above the upper ribbon AND smoothed base is higher than on the previous bar AND close is above the smoothed base.
Short: Close crosses below the lower ribbon AND smoothed base is lower than on the previous bar AND close is below the smoothed base.