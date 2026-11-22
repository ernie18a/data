Calculation: Friday close = close of the T1 bar at the offset to the most recent Friday, evaluated on T1 bars and carried to chart bars; use the T1 bar still forming when it is Friday
Long: flat and close < Friday close × (1 − entry threshold) OR long position and same-side entry count < maximum order count and close < average entry price × (1 − entry threshold)
Short: flat and close > Friday close × (1 + entry threshold) OR short position and same-side entry count < maximum order count and close > average entry price × (1 + entry threshold)
Exit: long, open profit / initial capital > profit threshold OR day of week is Monday
Exit: short, open profit / initial capital > profit threshold OR day of week is Monday
Calculation: Friday close = traded instrument close on the previous Friday at T1
Short: time >= start year, start month, and start day at 00:00 AND time <= stop year, stop month, and stop day at 00:00 AND Saturday or Sunday UTC AND ((flat AND close > Friday close * (1 + price deviation)) OR (short position AND close > average entry price * (1 + price deviation)))
Long: time >= start year, start month, and start day at 00:00 AND time <= stop year, stop month, and stop day at 00:00 AND Saturday or Sunday UTC AND ((flat AND close < Friday close * (1 - price deviation)) OR (long position AND close < average entry price * (1 - price deviation)))
Exit: long, time >= start year, start month, and start day at 00:00 AND time <= stop year, stop month, and stop day at 00:00 AND Monday UTC
Exit: short, time >= start year, start month, and start day at 00:00 AND time <= stop year, stop month, and stop day at 00:00 AND Monday UTC