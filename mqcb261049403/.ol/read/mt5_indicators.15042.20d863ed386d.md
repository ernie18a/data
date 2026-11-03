Calculation: JFATL = JMA-smoothed 39-bar Fast Adaptive Trend Line (FATL) of the configured applied price
Calculation: JFATL change = current JFATL − previous JFATL
Calculation: Change standard deviation = population standard deviation of JFATL changes over a lookback equal to the averaging lookback for those changes
Calculation: Signal thresholds = JFATL change standard deviation multiplied by two positive coefficients, the smaller coefficient being less than the larger
Long: JFATL change > smaller signal threshold, evaluated on the chart timeframe or on a higher timeframe's still-forming bar
Short: JFATL change < −smaller signal threshold, evaluated on the chart timeframe or on a higher timeframe's still-forming bar