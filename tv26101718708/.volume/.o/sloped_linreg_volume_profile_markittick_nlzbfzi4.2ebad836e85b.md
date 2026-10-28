Calculation: Linear regression slope = least-squares slope of the selected price source over the rolling window ending at the current bar.
Calculation: Buy-volume share = bullish volume divided by total volume allocated across sloped profile bins; classify a bar’s volume as bullish when close ≥ open and allocate it to bins in proportion to each bin’s overlap with the bar’s high–low range relative to the regression line.
Long: linear regression slope > 0 OR buy-volume share > 0.5
Short: linear regression slope ≤ 0 OR buy-volume share ≤ 0.5