Calculation: Base high = highest high over the preceding shorter lookback, excluding the current bar
Calculation: Base low = lowest low over the preceding shorter lookback, excluding the current bar
Calculation: Base range = base high − base low
Calculation: Zone score = 1 if base range is below its ATR threshold, plus 2 if the impulse body is above its ATR threshold, plus 2 if volume is above its moving-average threshold
Long: Base range < ATR × base-range threshold AND close > open AND close − open > ATR × impulse threshold AND volume > volume moving average × volume threshold AND close > base high AND zone score ≥ minimum score
Short: Base range < ATR × base-range threshold AND close < open AND open − close > ATR × impulse threshold AND volume > volume moving average × volume threshold AND close < base low AND zone score ≥ minimum score