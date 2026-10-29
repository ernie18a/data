Calculation: Modified price = (close + low) / 2 when close < open; (high + close) / 2 when close > open; otherwise close; if the result is zero, use close
Calculation: Smoothed modified price = selected smoothing average of modified price; in the higher-timeframe version, use the still-forming higher-timeframe bar sampled at its opening
Long: Current smoothed modified price > previous bar's smoothed modified price
Short: Current smoothed modified price < previous bar's smoothed modified price