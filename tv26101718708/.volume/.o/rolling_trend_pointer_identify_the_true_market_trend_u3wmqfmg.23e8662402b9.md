Calculation: Rolling VWAP = volume-weighted average of open over a rolling lookback including the current bar.
Calculation: Price distance = high minus Rolling VWAP when close is at or above Rolling VWAP; otherwise low minus Rolling VWAP. Apply the selected histogram smoothing method and lookback to this distance.
Calculation: Upper/lower deviation boundaries = positive/negative boundaries calculated independently from the latest rolling-lookback positive distances and absolute negative distances, using the selected weighted variance method and band multiplier; negate the lower boundary.
Calculation: Monthly/quarterly/semiannual/annual anchored VWAP = volume-weighted average of the selected price source from the start of the current calendar period through the current, still-forming bar. VWAP slope = current anchored VWAP minus its value the selected slope lookback bars earlier.
Long: Monthly anchored VWAP slope >= 0 AND each enabled quarterly, semiannual, and annual anchored VWAP slope >= 0 AND (synchronized mode is off OR smoothed price distance >= 0)
Long: Smoothed price distance > upper deviation boundary
Short: Monthly anchored VWAP slope < 0 AND each enabled quarterly, semiannual, and annual anchored VWAP slope < 0 AND (synchronized mode is off OR smoothed price distance < 0)
Short: Smoothed price distance < lower deviation boundary
Short: Neither bullish nor bearish anchored VWAP confirmation is synchronized with the corresponding price-distance sign