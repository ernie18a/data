Calculation: Fast EMA = exponential moving average of close over a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close over a longer lookback than the fast EMA
Calculation: Williams %R = 100 × (close − highest high over the lookback) / (highest high over the lookback − lowest low over the lookback)
Calculation: ATR buffer = exponential moving average of true range × configurable multiplier
Calculation: Long stop = min(entry-bar low, previous chart-bar low) − ATR buffer
Calculation: Long target = entry price + (entry price − long stop) × risk/reward ratio
Calculation: Short stop = max(entry-bar high, previous chart-bar high) + ATR buffer
Calculation: Short target = entry price − (short stop − entry price) × risk/reward ratio
Long: fast EMA > slow EMA AND (previous chart-bar Williams %R < −80 AND current chart-bar Williams %R > −80 AND close > fast EMA OR Williams %R < −80)
Short: fast EMA < slow EMA AND (previous chart-bar Williams %R > −20 AND current chart-bar Williams %R < −20 AND close < fast EMA OR Williams %R > −20)
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target