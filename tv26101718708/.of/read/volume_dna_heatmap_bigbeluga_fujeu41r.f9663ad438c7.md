Calculation: Volume Z-score = (current volume − rolling mean volume) / rolling standard deviation of volume
Calculation: Spread Z-score = (current high-low spread − rolling mean high-low spread) / rolling standard deviation of high-low spread
Long: close >= open AND Volume Z-score >= volume threshold AND Spread Z-score >= 0.5 × spread threshold
Short: close < open AND Volume Z-score >= volume threshold AND Spread Z-score >= 0.5 × spread threshold