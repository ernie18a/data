Calculation: reference-timeframe return = (close of the still-forming bar on the reference timeframe - close of the last completed bar on the reference timeframe) / close of the last completed bar on the reference timeframe
Calculation: direction state = true if reference-timeframe return > threshold; false if reference-timeframe return < -threshold; otherwise the direction state of the previous bar
Long: direction state = true
Short: direction state = false
Exit: short, direction state = true
Exit: long, direction state = false