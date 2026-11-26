Calculation: rolling open-close volume flow = SUM(IF(high = low, 0, ((close - open) / (high - low)) * volume), lookback)
Long: rolling open-close volume flow >= 0
Short: rolling open-close volume flow < 0