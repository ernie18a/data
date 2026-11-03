Calculation: Aroon high and low scores = For each score, round 100 - (bars since the most recent highest high or lowest low, respectively, in the lookback including the current bar + 0.5) * 100 / lookback to the nearest integer. Calculate either on the chart timeframe or on a higher timeframe using its still-forming bar.
Calculation: Trend = Start at 0. Set to +1 when the high score > the low score AND the high score >= 50; set to -1 when the high score < the low score AND the low score >= 50; otherwise retain the preceding trend.
Calculation: Displayed trend = Start at 0. Set to +1 when trend changes from -1 to +1; set to -1 when trend changes from +1 to -1; otherwise retain the preceding displayed trend.
Long: displayed trend = +1
Short: displayed trend = -1