Calculation: Smoothed price derivative = the selected OHLC-derived price’s change from its value at the lookback bars earlier, divided by the lookback and smoothed by the selected moving-average method; calculated on the configured indicator timeframe using completed bars
Calculation: Positive-rising state = smoothed price derivative > 0 AND smoothed price derivative >= its value one bar earlier
Calculation: Positive-falling state = smoothed price derivative > 0 AND smoothed price derivative < its value one bar earlier
Calculation: Negative-rising state = smoothed price derivative < 0 AND smoothed price derivative > its value one bar earlier
Calculation: Negative-falling state = smoothed price derivative < 0 AND smoothed price derivative <= its value one bar earlier
Calculation: Zero state = smoothed price derivative = 0
Long: Positive-rising state AND NOT the prior bar's positive-rising state OR Negative-rising state AND (the prior bar's negative-falling state OR the prior bar's zero state)
Short: Negative-falling state AND NOT the prior bar's negative-falling state OR Positive-falling state AND (the prior bar's positive-rising state OR the prior bar's zero state)
Exit: long, Positive-falling state OR Negative-falling state
Exit: short, Positive-rising state OR Negative-rising state