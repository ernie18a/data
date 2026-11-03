Calculation: Front basis = front-month futures close minus spot index close, using the higher-timeframe last completed bar
Calculation: Second basis = second-month futures close minus spot index close, using the higher-timeframe last completed bar
Long: front basis > threshold AND second basis > threshold
Short: front basis < -threshold AND second basis < -threshold
Exit: long, front basis < -threshold AND second basis < -threshold