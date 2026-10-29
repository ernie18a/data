Calculation: Timeframe score = ((previous chart bar close − lowest low of the previous lookback completed bars on that timeframe) / (highest high of those bars − lowest low of those bars)) × 100 − 50; use 0 if the high equals the low. Use the chart timeframe for one score and higher timeframes for the others; use only completed bars for each range.
Calculation: Total score = weighted average of the timeframe scores, using each timeframe’s configurable importance weight.
Long: Position is flat AND total score > sensitivity
Short: Position is flat AND total score < 0
Exit: Short, total score > sensitivity
Exit: Long, total score < 0
Exit: Long, low ≤ entry price − stop distance OR high ≥ entry price + take-profit distance
Exit: Short, high ≥ entry price + stop distance OR low ≤ entry price − take-profit distance