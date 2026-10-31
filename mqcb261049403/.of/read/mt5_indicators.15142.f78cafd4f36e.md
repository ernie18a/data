Calculation: Double-smoothed average = apply a Jurik moving average to a selected OHLC-derived price, then apply a second Jurik moving average with independently selectable length and phase to the result.
Calculation: Change = current double-smoothed average minus its preceding value.
Calculation: Deviation = population standard deviation of the latest changes over a configurable lookback, including the current change.
Calculation: Rounded change and thresholds = round the change and each of two independently parameterized multiples of deviation to the chosen price precision plus two decimal places.
Calculation: Higher-timeframe values = calculate the same average, change, deviation, and thresholds on a higher timeframe; capture their values on the first chart bar of each higher-timeframe bar and hold them until the next higher-timeframe bar. In live calculation the captured higher-timeframe bar is still forming; historical recalculation uses its completed value.
Long: Current double-smoothed average > preceding double-smoothed average.
Short: Current double-smoothed average < preceding double-smoothed average.
Long: Rounded change > first threshold AND rounded change <= second threshold.
Long: Rounded change > second threshold.
Short: Rounded change < negative first threshold AND rounded change >= negative second threshold.
Short: Rounded change < negative second threshold.
Long: Captured higher-timeframe double-smoothed average > its preceding higher-timeframe value.
Short: Captured higher-timeframe double-smoothed average < its preceding higher-timeframe value.
Long: Captured higher-timeframe rounded change > first captured higher-timeframe threshold AND captured higher-timeframe rounded change <= second captured higher-timeframe threshold.
Long: Captured higher-timeframe rounded change > second captured higher-timeframe threshold.
Short: Captured higher-timeframe rounded change < negative first captured higher-timeframe threshold AND captured higher-timeframe rounded change >= negative second captured higher-timeframe threshold.
Short: Captured higher-timeframe rounded change < negative second captured higher-timeframe threshold.