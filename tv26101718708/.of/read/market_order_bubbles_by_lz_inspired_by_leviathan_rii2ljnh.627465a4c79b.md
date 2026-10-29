Calculation: Tiny-range bar = high − low < minimum-range multiple × ATR(14), or high = low.
Calculation: Estimated buy volume = volume × (close − low) / (high − low), set to 0 on tiny-range bars.
Calculation: Estimated sell volume = volume × (high − close) / (high − low), set to 0 on tiny-range bars.
Calculation: Buy/sell surge threshold = rolling percentile of the corresponding estimated volume; three percentile levels share a lookback and increase in level, and the lowest level qualifies as a surge.
Calculation: Buy price efficiency = (close − low) / (high − low); sell price efficiency = (high − close) / (high − low); either equals 0.5 when high = low.
Long: Estimated sell volume ≥ sell surge threshold AND sell price efficiency < exhaustion threshold
Short: Estimated buy volume ≥ buy surge threshold AND buy price efficiency < exhaustion threshold