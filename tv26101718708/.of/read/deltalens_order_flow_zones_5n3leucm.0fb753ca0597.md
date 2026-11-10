Calculation: Delta = volume if close >= open; otherwise -volume. Cumulative delta is the running sum of delta.
Calculation: Pressure = (z-score of EMA of cumulative delta minus z-score of EMA of close) multiplied by relative volume. Both EMAs and their z-scores use the same lookback. Relative volume is volume divided by its SMA over a separate reference lookback, or 1 if unavailable. A z-score is (value minus SMA) divided by standard deviation, or 0 if the standard deviation is not positive.
Calculation: Up spike = pressure minus its reference-lookback SMA > a threshold multiplied by its reference-lookback standard deviation. Down spike = its reference-lookback SMA minus pressure > the same threshold multiplied by its reference-lookback standard deviation.
Calculation: Raw effort = absolute delta multiplied by volume divided by its SMA over an effort-volume lookback; use 1 for the volume ratio if unavailable. Effort = rounded percentile rank of raw effort over a separate ranking lookback, or 0 if unavailable. Efficiency = rounded 100 times the percentile rank of absolute close-to-previous-close change divided by the percentile rank of raw effort, using the same ranking lookback; make it negative if delta and the close change are misaligned, clamp it to the range -999 to 999, and use 0 if the effort percentile rank is not positive. Delta and close change are aligned when delta >= 0 and close >= previous close, or delta < 0 and close < previous close.
Calculation: Climax = effort >= its minimum AND either spike condition AND efficiency > its minimum. Absorption = climax is false AND effort >= its separate minimum AND efficiency <= its maximum AND high minus low >= a multiple of ATR.
Calculation: Bubble delta = divide the chart bar's high-low range into equal bins; assign each completed lower-timeframe bar's signed volume, positive when its close >= open and negative otherwise, to the bin containing the midpoint of its high-low range clipped to the chart bar's range. Bubble delta is the signed sum in the bin with the greatest absolute sum, breaking ties toward the lowest bin. Use 0 when the chart bar fails the volume gate or has no completed lower-timeframe bars. The volume gate is chart-bar volume >= a multiple of its SMA over a bubble lookback. Bubble threshold = a configurable upper percentile of absolute bubble delta over that same lookback.
Calculation: A spike cluster contains same-direction spike bars, permits one intervening non-spike bar, and ends when an opposite spike occurs or a second consecutive non-spike bar occurs. Divide the cluster's high-low range into equal bins. For each completed lower-timeframe bar belonging to a spike bar, clip its high-low range to that chart bar, assign its signed volume to the midpoint bin if its range spans at most two bins, and otherwise distribute signed volume across overlapping bins in proportion to price-range overlap. Cluster bin delta is the signed volume sum in each bin.
Long: Up spike.
Short: Down spike.
Long: Delta > 0.
Short: Delta < 0.
Long: Effort > 0 AND effort >= its tape-label minimum.
Short: Effort = 0 AND effort >= its tape-label minimum.
Long: Climax AND delta > 0.
Short: Climax AND delta <= 0.
Long: Absorption AND delta > 0.
Short: Absorption AND delta <= 0.
Long: Volume gate AND bubble threshold > 0 AND bubble delta >= bubble threshold.
Short: Volume gate AND bubble threshold > 0 AND bubble delta <= -bubble threshold.
Long: A valid spike cluster ends AND its direction is up.
Short: A valid spike cluster ends AND its direction is down.
Long: A valid spike cluster ends AND any cluster bin delta > 0.
Short: A valid spike cluster ends AND any cluster bin delta < 0.