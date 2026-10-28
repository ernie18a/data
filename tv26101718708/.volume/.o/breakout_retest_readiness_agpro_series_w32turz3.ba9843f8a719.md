Calculation: Prior structure high/low = highest high / lowest low over the lookback, excluding the current bar
Calculation: Breakout buffer = ATR × breakout-buffer parameter
Calculation: Retest pocket = broken structure level ± (breakout-time ATR × pocket-width parameter)
Long: On a confirmed bar, close > prior structure high + breakout buffer AND previous close ≤ prior structure high + 0.25 × breakout buffer
Short: On a confirmed bar, close < prior structure low − breakout buffer AND previous close ≥ prior structure low − 0.25 × breakout buffer
Long: Active bullish retest has been touched within its time limit AND best extension ≥ minimum separation AND remaining target room ≥ minimum room AND acceptance score ≥ minimum score AND close ≥ broken level + 0.10 × pocket width
Short: Active bearish retest has been touched within its time limit AND best extension ≥ minimum separation AND remaining target room ≥ minimum room AND acceptance score ≥ minimum score AND close ≤ broken level − 0.10 × pocket width
Exit: Long, after a retest touch, close < broken level − 0.70 × pocket width OR close < invalidation shelf
Exit: Short, after a retest touch, close > broken level + 0.70 × pocket width OR close > invalidation shelf