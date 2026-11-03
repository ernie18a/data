Calculation: Volume-weighted price = sum(volume × (high + low + 2 × close) / 4) / sum(volume) over a shorter lookback
Calculation: Normalized oscillator = 100 × (current volume-weighted price − lowest volume-weighted price over a longer lookback) / (highest − lowest volume-weighted price over that longer lookback) − 50
Calculation: First smoothed oscillator = apply a smoothing method to the normalized oscillator
Calculation: Second smoothed oscillator = apply the same smoothing method with the same parameters to the first smoothed oscillator
Long: First smoothed oscillator > second smoothed oscillator AND (first smoothed oscillator > upper level OR (first smoothed oscillator > lower level AND second smoothed oscillator ≤ lower level))
Short: First smoothed oscillator ≤ second smoothed oscillator AND (first smoothed oscillator < lower level OR (second smoothed oscillator > upper level AND first smoothed oscillator ≤ upper level))