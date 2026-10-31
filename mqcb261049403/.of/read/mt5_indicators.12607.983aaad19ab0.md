Calculation: Volume-weighted price = rolling sum of selected bar price multiplied by volume divided by the greater of rolling volume sum and 1, including the current bar
Calculation: Normalized value = 100 × (volume-weighted price − its rolling minimum) / max(its rolling maximum − its rolling minimum, minimum price increment) − 50; extrema include the current bar
Calculation: First smoothed value = moving average of normalized value
Calculation: Second smoothed value = moving average of the first smoothed value, using the same method and parameters; calculations use either chart bars or the still-forming bar of a higher timeframe
Long: First smoothed value > second smoothed value
Short: First smoothed value <= second smoothed value