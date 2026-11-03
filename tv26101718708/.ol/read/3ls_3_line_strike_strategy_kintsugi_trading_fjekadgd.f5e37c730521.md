Calculation: Bullish 3-line-strike = the previous three bars each closed above open, and the current bar closed above open after the previous bar closed below open, with the current body larger than the previous body
Calculation: Bearish 3-line-strike = the previous three bars each closed below open, and the current bar closed below open after the previous bar closed above open, with the current body larger than the previous body
Calculation: Volume threshold = simple moving average of volume over a configurable lookback × configurable multiplier
Calculation: Fast and slow trend averages = simple moving averages of close, with the fast average using a shorter lookback than the slow average
Long: Bullish 3-line-strike
Long: Bullish 3-line-strike AND volume > volume threshold AND fast trend average > slow trend average AND position is flat AND (session filter is disabled OR bar time is within the configured session)
Short: Bearish 3-line-strike
Short: Bearish 3-line-strike AND volume > volume threshold AND fast trend average < slow trend average AND position is flat AND (session filter is disabled OR bar time is within the configured session)
Exit: long, bar low <= long stop OR bar high >= long target when a target is enabled
Exit: short, bar high >= short stop OR bar low <= short target when a target is enabled