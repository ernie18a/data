Calculation: signed-volume average = SUM(IF(close > open, volume, IF(close < open, -volume, 0)), lookback) / lookback
Calculation: directional state = 1 if signed-volume average > upper threshold, -1 if signed-volume average < lower threshold, otherwise previous directional state (initially 0)
Long: directional state = 1
Short: directional state = -1