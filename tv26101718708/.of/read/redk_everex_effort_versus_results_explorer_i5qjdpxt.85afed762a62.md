Calculation: Analysis bars = chart bars, or bars aggregated to a higher or lower timeframe; use the last completed analysis bar at each chart bar.
Calculation: Normalization(x) = a positive, increasing step function of x divided by its lookback moving average; use the same step boundaries and outputs for volume, absolute candle body, and absolute close change. The lookback average is either an SMA or the selected flow moving-average type.
Calculation: Normalized volume = normalization(volume), or the maximum normalization value when volume is missing.
Calculation: Price strength = the mean of: close location within the current bar scaled from -1 to 1; (close - open) / (high - low); signed normalized absolute candle body; close location within the combined current and previous bar range scaled from -1 to 1; close change divided by the combined current and previous bar range; and signed normalized absolute close change. The combined range is the highest high minus the lowest low of the two bars.
Calculation: Bar flow = price strength multiplied by normalized volume.
Calculation: Smoothed relative flow = WMA smoothing of (average positive bar flow - average absolute negative bar flow) / (average positive bar flow + average absolute negative bar flow), using the same selected moving-average type and length for both averages. The bias uses a longer averaging length and may use a different moving-average type; both use the same WMA smoothing length.
Calculation: Effort-result ratio = absolute price strength divided by normalized volume.
Calculation: Large supported move = absolute price strength >= a price-strength threshold AND normalized volume >= a volume threshold.
Long: Smoothed relative flow >= 0.
Short: Smoothed relative flow < 0.
Long: Smoothed relative flow using the longer bias length >= 0.
Short: Smoothed relative flow using the longer bias length < 0.
Long: Bar flow > 0.
Short: Bar flow <= 0.
Long: Price strength > 0 AND effort-result ratio >= the ease-of-move threshold AND large supported move is false.
Short: Price strength <= 0 AND effort-result ratio >= the ease-of-move threshold AND large supported move is false.
Long: Price strength > 0 AND effort-result ratio <= the compression threshold.
Short: Price strength <= 0 AND effort-result ratio <= the compression threshold.
Long: Price strength > 0 AND large supported move is true.
Short: Price strength <= 0 AND large supported move is true.