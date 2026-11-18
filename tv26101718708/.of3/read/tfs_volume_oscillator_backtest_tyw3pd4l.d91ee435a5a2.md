Calculation: signed volume average = SUM(IF close > open THEN volume ELSE IF close < open THEN -volume ELSE 0, lookback) / lookback
Calculation: threshold state = IF signed volume average > upper threshold THEN long ELSE IF signed volume average < lower threshold THEN short ELSE previous threshold state, initially neutral
Calculation: signal direction = threshold state with long and short swapped when the reverse parameter is enabled; neutral remains neutral
Long: signal direction = long
Short: signal direction = short