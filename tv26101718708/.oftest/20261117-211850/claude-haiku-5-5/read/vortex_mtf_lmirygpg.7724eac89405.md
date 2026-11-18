Calculation: VI+ = sum over the period bars ending with the bar still forming of abs(high - previous low), divided by sum over the same bars of true range, using bars of timeframe T
Calculation: VI- = sum over the period bars ending with the bar still forming of abs(low - previous high), divided by sum over the same bars of true range, using bars of timeframe T
Calculation: true range = max(high - low, abs(high - previous close), abs(low - previous close))
Long: VI+ > VI- AND VI+[1] <= VI-[1]
Short: VI- > VI+ AND VI-[1] <= VI+[1]