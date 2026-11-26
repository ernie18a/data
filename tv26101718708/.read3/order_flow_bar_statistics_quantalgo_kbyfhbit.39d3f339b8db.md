Calculation: delta = aggressive buy volume - aggressive sell volume, or when aggressive volume is unavailable, volume * (2 * close - high - low) / (high - low), or 0 if high = low
Calculation: net long = (delta + (open interest - open interest[1])) / 2 for split positioning, or open interest - open interest[1] if close - close[1] and open interest - open interest[1] are both positive or both negative, else 0, for quadrant positioning
Calculation: net short = (delta - (open interest - open interest[1])) / 2 for split positioning, or open interest - open interest[1] if close - close[1] and open interest - open interest[1] have opposite nonzero signs, else 0, for quadrant positioning
Long: delta crosses above 0
Short: delta crosses below 0
Long: net long crosses above 0
Short: net short crosses above 0