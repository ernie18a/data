Calculation: Bar delta = bar volume when close ≥ open; otherwise −bar volume.
Calculation: Cumulative delta = running sum of bar delta.
Calculation: Divergence pressure = (z-score of smoothed cumulative delta − z-score of smoothed close) × bar volume / its longer-lookback average.
Calculation: Divergence spike = divergence pressure differs from its longer-lookback average by more than the spike threshold times its standard deviation; positive and negative deviations are buy-side and sell-side spikes, respectively.
Calculation: Effort = percentile rank of absolute bar delta × bar volume / its shorter-lookback average, ranked over a longer lookback.
Calculation: Efficiency = signed ratio of the percentile rank of absolute close-to-close movement to the percentile rank of effort; positive when delta and close movement have the same direction, negative otherwise.
Calculation: Large aggression = the lower-timeframe price bin within the current bar with the greatest absolute net delta; its direction is the sign of net delta in that bin.
Long: positive divergence spike OR positive-delta climax OR positive-delta absorption OR large aggression is buy-directed and qualifies by the volume and rolling percentile thresholds.
Short: negative divergence spike OR negative-delta climax OR negative-delta absorption OR large aggression is sell-directed and qualifies by the volume and rolling percentile thresholds.
Exit: