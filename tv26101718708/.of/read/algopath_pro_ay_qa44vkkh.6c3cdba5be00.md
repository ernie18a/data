Calculation: Threshold = ATR(lookback) * multiplier, computed on chart-timeframe bars up to and including the current bar
Calculation: Size = absolute value of (close - open) of the current bar; the high - low range is an allowed alternative
Calculation: Gap = open of the bar at the New York regular-session open time minus open of the most recent earlier bar at the New York regular-session close time
Long: Size > Threshold AND close > open
Short: Size > Threshold AND close < open
Long: current bar is the bar at the New York regular-session open time AND Gap > 0
Short: current bar is the bar at the New York regular-session open time AND Gap < 0