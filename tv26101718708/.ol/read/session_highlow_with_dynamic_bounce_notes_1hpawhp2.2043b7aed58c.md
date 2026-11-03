Calculation: Previous session high = highest high during the previous completed session
Calculation: Previous session low = lowest low during the previous completed session
Calculation: Bounce buffer = minimum price increment × buffer size in ticks
Long: Low <= Previous session low + Bounce buffer AND Low >= Previous session low AND Close > Previous session low + Bounce buffer
Short: High >= Previous session high - Bounce buffer AND High <= Previous session high AND Close < Previous session high - Bounce buffer