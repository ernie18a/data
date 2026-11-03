Calculation: Average seasonal daily step = mean of prior years’ Daily close-to-close percentage returns for the day immediately after the matching calendar-date anchor at the same offset; use the last completed Daily bar as the current anchor on intraday charts.
Calculation: Smoothed seasonal step = centered moving average of the average seasonal daily steps across the configured local window.
Calculation: Directional consistency = 100 × the greater of the counts of positive and negative historical daily steps divided by the number of valid steps at that offset.
Calculation: Seasonal step threshold = the greater of 0.01 percentage points and the mean absolute smoothed seasonal step across the configured local window multiplied by a strictness-dependent factor.
Calculation: Minimum consistency = a strictness-dependent percentage threshold.
Long: Smoothed seasonal step > Seasonal step threshold AND Directional consistency ≥ Minimum consistency
Short: Smoothed seasonal step < −Seasonal step threshold AND Directional consistency ≥ Minimum consistency