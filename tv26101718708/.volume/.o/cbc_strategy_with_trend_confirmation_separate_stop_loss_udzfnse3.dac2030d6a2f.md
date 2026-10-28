Calculation: CBC state = initialize bearish; retain the prior state unless close > the previous bar’s high, which makes it bullish, or close < the previous bar’s low, which makes it bearish
Calculation: Long target = entry-signal-bar close + ATR × configured profit-target multiple
Calculation: Short target = entry-signal-bar close − ATR × configured profit-target multiple
Long: CBC state changes from bearish to bullish AND slow EMA ≥ VWAP AND hour(datetime) ≥ configured start hour AND hour(datetime) < configured end hour AND (strong-flips-only is disabled OR low < previous bar’s low)
Short: CBC state changes from bullish to bearish AND slow EMA < VWAP AND hour(datetime) ≥ configured start hour AND hour(datetime) < configured end hour AND (strong-flips-only is disabled OR high > previous bar’s high)
Exit: Long, close ≤ previous bar’s low OR high ≥ long target
Exit: Short, close ≥ previous bar’s high OR low ≤ short target