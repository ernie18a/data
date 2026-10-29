Calculation: ATR = average true range
Calculation: Prior high = highest high over the structure lookback, excluding the current bar
Calculation: Prior low = lowest low over the structure lookback, excluding the current bar
Calculation: Breakout buffer = ATR × breakout-buffer parameter × sensitivity factor
Long: confirmed bar close > prior high + breakout buffer AND previous close ≤ prior high + 0.25 × breakout buffer
Short: confirmed bar close < prior low − breakout buffer AND previous close ≥ prior low − 0.25 × breakout buffer
Exit: long, close < breakout line − 0.70 × retest-pocket width OR close < invalidation level
Exit: short, close > breakout line + 0.70 × retest-pocket width OR close > invalidation level