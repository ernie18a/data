Calculation: Fast-window high and low = highest high and lowest low over the shorter lookback on the chart timeframe or a higher timeframe, using completed bars beginning with the last completed bar
Calculation: Slow-window high and low = highest high and lowest low over the longer lookback on the chart timeframe or a higher timeframe, using completed bars beginning with the last completed bar
Calculation: Buy-stop level = fast-window high + (fast-window high − fast-window low) × range multiplier, defined only when fast-window width equals slow-window width
Calculation: Sell-stop level = fast-window low − (fast-window high − fast-window low) × range multiplier, defined only when fast-window width equals slow-window width
Long: high ≥ buy-stop level AND fast-window width = slow-window width
Short: low ≤ sell-stop level AND fast-window width = slow-window width