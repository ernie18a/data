Calculation: Fast EMA slope = fast EMA now − fast EMA at the longer slope lookback
Calculation: Long stop = min(signal-bar low, medium-term EMA) − ATR × stop multiplier, frozen at entry
Calculation: Short stop = max(signal-bar high, medium-term EMA) + ATR × stop multiplier, frozen at entry
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × reward-risk ratio
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × reward-risk ratio
Long: close crosses above the short-term EMA AND short-term EMA > medium-term EMA > long-term EMA AND fast EMA slope > 0
Short: close crosses below the short-term EMA AND short-term EMA < medium-term EMA AND short-term EMA < long-term EMA AND fast EMA slope < 0
Exit: long, short-term EMA crosses below medium-term EMA OR low ≤ long stop OR high ≥ long target
Exit: short, short-term EMA crosses above medium-term EMA OR high ≥ short stop OR low ≤ short target