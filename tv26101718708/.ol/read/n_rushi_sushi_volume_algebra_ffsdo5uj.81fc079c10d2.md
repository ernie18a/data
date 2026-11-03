Calculation: Volume ratio = current volume divided by volume from a configurable number of chart bars earlier
Calculation: Volume change percentage = (volume ratio − 1) × 100
Calculation: Price change percentage = (current close ÷ close from the same earlier bar − 1) × 100
Calculation: Score = weighted sum of volume change percentage, absolute price change percentage, and volume ratio capped at 3
Long: volume ratio > active-volume threshold AND price change percentage > 0 AND score ≥ minimum signal threshold
Short: volume ratio > active-volume threshold AND price change percentage < 0 AND score ≥ minimum signal threshold
Exit: long, low ≤ entry price − ATR × stop multiplier
Exit: short, high ≥ entry price + ATR × stop multiplier