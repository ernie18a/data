Calculation: Timeframe state = For each of eight configurable timeframes, calculate the close and an EMA or SMA of close using the same type and length across timeframes. Compare the MA with its value on the preceding bar of that timeframe. State is 2 if close > MA AND MA > preceding MA; 1 if close > MA AND MA <= preceding MA; -2 if close < MA AND MA < preceding MA; -1 if close < MA AND MA >= preceding MA; otherwise 0. A timeframe may be higher than, lower than, or equal to the chart timeframe. For a higher timeframe, use the last completed bar on historical chart bars and the still-forming bar on the live chart bar. For a lower timeframe, use the last available intrabar within the chart bar: completed on historical chart bars and potentially still forming on the live chart bar. For the chart timeframe, use the current chart bar.
Long: Any timeframe state = 2 OR any timeframe state = 1
Short: Any timeframe state = -2 OR any timeframe state = -1
Long: Every timeframe state = 2
Long: Every timeframe state > 0 AND at least one timeframe state = 1
Short: Every timeframe state = -2
Short: Every timeframe state < 0 AND at least one timeframe state = -1
Long: Every timeframe state = 2 AND on the preceding chart bar at least one timeframe state != 2
Long: Every timeframe state > 0 AND at least one timeframe state = 1 AND on the preceding chart bar at least one timeframe state <= 0
Short: Every timeframe state = -2 AND on the preceding chart bar at least one timeframe state != -2
Short: Every timeframe state < 0 AND at least one timeframe state = -1 AND on the preceding chart bar at least one timeframe state >= 0