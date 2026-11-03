Calculation: Buy volume estimate = volume × (close − low) / (high − low), or volume / 2 when high = low
Calculation: Sell volume estimate = volume × (high − close) / (high − low), or volume / 2 when high = low
Calculation: Smoothed buy and sell volume = EMA of each respective volume estimate, using the same lookback
Calculation: Imbalance (%) = round(100 × (smoothed buy volume − smoothed sell volume) / (smoothed buy volume + smoothed sell volume))
Long: Imbalance > 5
Short: Imbalance < −5