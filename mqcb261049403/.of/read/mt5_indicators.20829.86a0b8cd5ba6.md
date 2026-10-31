Calculation: Normalized range = 100 × moving average of (close − low) / max(moving average of true range, positive price floor); the two moving averages have independently selectable methods and lookbacks.
Calculation: Higher-timeframe normalized range = normalized range calculated on the higher timeframe using its still-forming bar at the start of each higher-timeframe period, carried forward across the chart bars in that period.
Long: Chart-timeframe normalized range > middle threshold OR higher-timeframe normalized range > middle threshold.
Short: Chart-timeframe normalized range < middle threshold OR higher-timeframe normalized range < middle threshold.
Long: Higher-timeframe normalized range on the selected chart bar > upper threshold AND its value on the preceding chart bar <= upper threshold.
Short: Higher-timeframe normalized range on the selected chart bar < lower threshold AND its value on the preceding chart bar >= lower threshold.