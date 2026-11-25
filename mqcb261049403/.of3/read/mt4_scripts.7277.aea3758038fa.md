Long: At the opening of each T1 bar, the last completed T1 bar closes above its open
Short: At the opening of each T1 bar, the last completed T1 bar closes below its open
Exit Long, high >= entry price + profit target
Exit Short, low <= entry price - profit target
Calculation: Maximum high since entry = highest(high, bars since entry)
Calculation: Minimum low since entry = lowest(low, bars since entry)
Exit Long, low <= entry price AND Maximum high since entry >= entry price + profit target
Exit Short, high >= entry price AND Minimum low since entry <= entry price - profit target
Exit Long, low <= Maximum high since entry - trailing distance AND Maximum high since entry >= entry price + profit target
Exit Short, high >= Minimum low since entry + trailing distance AND Minimum low since entry <= entry price - profit target