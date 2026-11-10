Calculation: Scheduled event = third Friday of any month OR fourth Friday of June. Dividend events cannot be identified from the available backtest fields.
Calculation: Up volume = rolling sum of volume on non-event bars with close greater than the previous close; down volume = rolling sum of volume on non-event bars with close less than the previous close, over the same lookback.
Calculation: Volume ratio = up volume / max(down volume, 1).
Calculation: Upper and lower bands = configurable manual thresholds, or, when auto-calibration is enabled and sufficient valid observations exist, exp(median of log(volume ratio) over a longer lookback ± a configurable width multiplied by its standard deviation); use the upper sign for the upper band and the lower sign for the lower band. Exclude nonpositive ratios from the logarithm; use manual bands until both automatic bands are available.
Calculation: Regime = initially neutral. On each closed non-event bar, retain the regime if up volume plus down volume is zero; otherwise select accumulation if volume ratio >= upper band, distribution if volume ratio < upper band AND volume ratio <= lower band, and the current regime otherwise. Change regime after the same different candidate is selected for a configurable number of non-event bars; event bars leave the pending candidate and count unchanged, and a candidate equal to the current regime resets them.
Calculation: Relative volume = volume / the previous bar's simple moving average of volume; undefined if that average is not positive.
Calculation: Up-to-down average volume ratio = (up volume / number of non-event bars with rising close) / (down volume / number of non-event bars with falling close), using the volume-ratio lookback; undefined if either count is zero or the denominator is not positive.
Calculation: Clean OBV change = rolling sum over the volume-ratio lookback of volume for non-event bars with rising close minus volume for non-event bars with falling close.
Calculation: Close-location value = (2 × close − high − low) / (high − low) when high > low, otherwise zero.
Calculation: Clean accumulation/distribution change = rolling sum over the volume-ratio lookback of close-location value × volume on non-event bars.
Calculation: Volume-weighted close location = rolling sum of close-location value × volume on non-event bars / max(rolling sum of volume on non-event bars, 1), using the volume-ratio lookback.
Calculation: Heavy selling count = rolling count over a separate lookback of non-event bars where previous close > 0 AND (close − previous close) / previous close < a negative threshold AND volume > previous volume AND relative volume > a threshold.
Long: Regime = accumulation.
Short: Regime = distribution.
Long: Regime = accumulation AND previous regime != accumulation.
Short: Regime = distribution AND previous regime != distribution.
Long: Volume ratio >= upper band.
Short: Volume ratio < upper band AND volume ratio <= lower band.
Long: Current bar is not a scheduled event AND relative volume > a high-volume threshold AND close > open.
Short: Current bar is not a scheduled event AND relative volume > a high-volume threshold AND close < open.
Long: Up-to-down average volume ratio > an upper threshold.
Short: Up-to-down average volume ratio < a lower threshold.
Long: Clean OBV change > 0.
Short: Clean OBV change < 0.
Long: Clean accumulation/distribution change > 0.
Short: Clean accumulation/distribution change < 0.
Long: Volume-weighted close location > a positive threshold.
Short: Volume-weighted close location < a negative threshold.
Long: Heavy selling count < a lower count threshold.
Short: Heavy selling count >= a higher count threshold.