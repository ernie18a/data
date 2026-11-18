Calculation: Signed volume = SUM(IF close > open THEN volume ELSE -volume, lookback bars including current bar)
Long: Signed volume >= 0
Short: Signed volume < 0