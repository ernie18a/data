Calculation: Midpoint = (high + low) / 2
Calculation: Scaled volume = stdev(volume, lookback) != 0 ? volume / stdev(volume, lookback) : 0
Long: bubble display enabled AND scaled volume >= absorption threshold AND midpoint <= min(open, close) AND midpoint >= low
Short: bubble display enabled AND scaled volume >= absorption threshold AND midpoint >= max(open, close) AND midpoint <= high