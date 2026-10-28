Calculation: Estimated buy volume = volume × (close − low) / (high − low), or volume / 2 when high = low; smooth with an EMA.
Calculation: Estimated sell volume = volume × (high − close) / (high − low), or volume / 2 when high = low; smooth with an EMA.
Calculation: Bid/ask imbalance (%) = round(100 × (smoothed estimated buy volume − smoothed estimated sell volume) / (smoothed estimated buy volume + smoothed estimated sell volume)).
Long: Bid/ask imbalance (%) > 5
Short: Bid/ask imbalance (%) < −5