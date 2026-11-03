Calculation: Rally day = number of chart bars since the most recent occurrence of the lowest low in the rally lookback, plus one
Calculation: Distribution day = close meets the configured decline threshold below the previous close AND volume > previous volume
Calculation: Fifth distribution-day low = low of the fifth most recent distribution day within the last 20 chart bars
Long: Rally day >= 4 AND rally day <= 7 AND close gain from previous close meets the configured FTD threshold AND volume > previous volume
Short: Distribution day
Exit: Long, fifth distribution-day low is defined AND close < fifth distribution-day low