Calculation: lower wick ratio = (min(open, close) - low) / (high - low)
Calculation: trailing stop = maximum, since the position opened, of (low - ATR × stop multiplier)
Long: volume > short-term average volume × relative-volume threshold AND 2 × ATR > 2 × standard deviation of close AND lower wick ratio > wick-ratio threshold
Exit: long, low <= trailing stop