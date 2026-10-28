Calculation: Anchored VWAP = volume-weighted average of the selected price source within the current anchor period, including the current bar.
Calculation: VWAP standard deviation bands = anchored VWAP plus or minus the standard deviation distance multiplied by the band multiplier; outer bands use twice that distance.
Long: Previous close ≤ previous upper band and current close > current upper band AND current VWAP > previous VWAP
Short: Previous close ≥ previous lower band and current close < current lower band AND current VWAP < previous VWAP
Exit: Long, previous close ≥ previous outer upper band and current close < current outer upper band
Exit: Short, previous close ≤ previous outer lower band and current close > current outer lower band