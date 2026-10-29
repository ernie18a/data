Calculation: Ease of Movement = ((current bar median price − previous bar median price) × current bar median price) / (2 × current bar tick volume), where median price = (high + low) / 2; use 0 when volume is 0
Calculation: Smoothed Ease of Movement = a smoothing of Ease of Movement
Calculation: Signal line = a smoothing of Smoothed Ease of Movement, with a shorter lookback than the smoothing used for Smoothed Ease of Movement
Long: Ease of Movement > 0 OR Smoothed Ease of Movement > Signal line
Short: Ease of Movement < 0 OR Smoothed Ease of Movement < Signal line