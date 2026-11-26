Calculation: First average = selected moving average of close using its own lookback and type on T1’s still-forming bar, sampled on chart bars
Calculation: Second average = selected moving average of close using its own lookback and type on T2’s still-forming bar, sampled on chart bars
Calculation: Smoothed third average = SMA of the selected moving average of close using its own lookback and type on T3’s still-forming bar, sampled on chart bars, with a lookback equal to the rounded ratio of T3 duration to chart-timeframe duration
Long: First average crosses above second average AND smoothed third average is greater than its previous chart-bar value
Short: First average crosses below second average AND smoothed third average is less than its previous chart-bar value
Exit: Long, first average crosses below second average AND smoothed third average is greater than or equal to its previous chart-bar value
Exit: Short, first average crosses above second average AND smoothed third average is less than or equal to its previous chart-bar value