Calculation: Volume delta = Sum signed volume across the chart bar's completed lower-timeframe bars. Assign each lower-timeframe bar's volume a positive sign if its close is above its open, or a negative sign if below; if equal, use the sign of its close change from the preceding lower-timeframe bar; if that is also zero, reuse the last assigned sign, defaulting to positive if none exists.
Calculation: Cumulative volume delta = Cumulative sum of either volume delta or volume delta divided by the sum of lower-timeframe volumes in the chart bar. Optionally reset the sum to zero before adding the current bar's value at a configurable higher-timeframe bar opening, at a configurable time contained in a chart bar, or on a Supertrend direction change, Aroon crossover or crossunder, or Parabolic SAR crossover or crossunder of close. The higher-timeframe reset uses the opening of the bar still forming.
Calculation: Cumulative volume delta average = Simple moving average of cumulative volume delta when resets are disabled; otherwise, the arithmetic mean of cumulative volume delta since and including the latest reset bar.
Long: Volume delta > 0
Short: Volume delta <= 0
Long: Cumulative volume delta > 0
Short: Cumulative volume delta <= 0
Long: No reset on the current bar AND cumulative volume delta average > 0
Short: No reset on the current bar AND cumulative volume delta average <= 0
Long: Supertrend changes to an uptrend
Short: Supertrend changes to a downtrend
Long: Aroon up crosses above Aroon down
Short: Aroon up crosses below Aroon down
Long: Parabolic SAR crosses below close
Short: Parabolic SAR crosses above close