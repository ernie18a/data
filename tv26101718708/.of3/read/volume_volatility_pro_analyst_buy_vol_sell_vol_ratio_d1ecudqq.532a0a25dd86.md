Calculation: estimated buy volume = volume * (abs(close - open) + min(open, close) - low) / (high - low if high != low else 1)
Calculation: estimated sell volume = volume * (abs(close - open) + high - max(open, close)) / (high - low if high != low else 1)
Calculation: buy/sell volume ratio = estimated buy volume if estimated sell volume == 0, otherwise estimated buy volume / estimated sell volume
Long: buy/sell volume ratio >= balance threshold
Short: buy/sell volume ratio < balance threshold