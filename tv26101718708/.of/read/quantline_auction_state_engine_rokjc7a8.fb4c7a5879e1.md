Calculation: Prior range high/low = highest high/lowest low over the lookback, excluding the current bar; lock both values when a test starts.
Calculation: Efficiency ratio = absolute net close change over its lookback divided by the sum of absolute close changes over that lookback.
Calculation: Relative volume = current volume divided by its moving average.
Long: Unarmed AND close > prior range high + ATR × break distance
Long: Testing down AND close > locked range low + ATR × failure distance
Long: Accepted down AND close > locked range low + ATR × failure distance
Long: Testing up AND accumulated qualifying closes beyond locked range high reach the required count AND efficiency ratio ≥ minimum AND (relative-volume filter disabled OR relative volume ≥ minimum)
Long: Accepted up AND no prior retest since acceptance AND current bar is after the acceptance bar AND low ≤ locked range high + ATR × retest tolerance AND close ≥ locked range high
Short: Unarmed AND close < prior range low − ATR × break distance
Short: Testing up AND close < locked range high − ATR × failure distance
Short: Accepted up AND close < locked range high − ATR × failure distance
Short: Testing down AND accumulated qualifying closes beyond locked range low reach the required count AND efficiency ratio ≥ minimum AND (relative-volume filter disabled OR relative volume ≥ minimum)
Short: Accepted down AND no prior retest since acceptance AND current bar is after the acceptance bar AND high ≥ locked range low − ATR × retest tolerance AND close ≤ locked range low