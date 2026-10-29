Calculation: Bull Bear Power = (high − EMA(close, shorter lookback)) + (low − EMA(close, shorter lookback))
Calculation: Z-score = (Bull Bear Power − its longer-lookback SMA) / its longer-lookback standard deviation
Calculation: Volume ratio = current volume / its longer-lookback SMA
Calculation: Price and volume percentile ranks = percentile ranks of the oldest close and volume, respectively, in their rolling lookback windows
Calculation: Take-profit factor = average of the volume score and price score; each score is its high, medium, or low factor when its ratio or percentile rank exceeds the corresponding high, medium, or low threshold, otherwise 0.8
Calculation: Take-profit prices = entry price ± (ATR × each of three take-profit multipliers × take-profit factor); add for long and subtract for short
Long: On a confirmed bar, Z-score crosses above the upper threshold (current Z-score > threshold AND previous Z-score ≤ threshold)
Short: On a confirmed bar, Z-score crosses below the negative upper threshold (current Z-score < −threshold AND previous Z-score ≥ −threshold)
Exit: Long, Z-score crosses below zero (current Z-score < 0 AND previous Z-score ≥ 0) OR bar high reaches or exceeds any take-profit price
Exit: Short, Z-score crosses above zero (current Z-score > 0 AND previous Z-score ≤ 0) OR bar low reaches or falls below any take-profit price