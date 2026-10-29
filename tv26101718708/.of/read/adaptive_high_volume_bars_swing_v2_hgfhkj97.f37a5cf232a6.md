Calculation: Absolute volume Z-score = (current volume − moving average volume over the selected lookback) / standard deviation of volume over the same lookback
Calculation: Volume acceleration score = (current volume − previous bar volume) / standard deviation of volume over the same lookback
Calculation: Volume level = classify each enabled score as 0 below the high threshold, 1 at or above the high threshold, 2 at or above the higher very-high threshold, or 3 at or above the still-higher exceptional threshold; use the absolute score, acceleration score, or the greater of both, according to the selected detection mode
Long: close > open AND volume level >= 1
Short: close < open AND volume level >= 1