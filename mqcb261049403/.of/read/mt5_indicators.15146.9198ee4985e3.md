Calculation: Composite average = smooth the weighted sum of ten moving averages of the selected OHLC-derived price, using the same moving-average method and phase for all ten, with separately parameterized lengths and weights; the ten lengths range from shorter to longer. The smoothing method, length, and phase are independently parameterized.
Calculation: Change = composite average minus its previous-bar value.
Calculation: Deviation = population standard deviation of Change over a lookback including the current bar.
Calculation: Rounded change and thresholds = round Change and each of two independently parameterized multiples of Deviation to the price decimal precision plus two decimal places; the second multiplier is larger than the first.
Calculation: Evaluation series = calculate the composite average, Change, Deviation, and rounded thresholds either on the chart timeframe or on the higher timeframe using its still-forming bar and preceding higher-timeframe bars.
Long: Change > 0
Short: Change < 0
Long: (rounded change > first rounded threshold AND rounded change <= second rounded threshold) OR rounded change > second rounded threshold
Short: (rounded change < -first rounded threshold AND rounded change >= -second rounded threshold) OR rounded change < -second rounded threshold